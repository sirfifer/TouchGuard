//
//  main.c
//  TouchGuard
//
//  Originally created by SyntaxSoft 2016.
//  https://github.com/thesyntaxinator/TouchGuard
//
//  Enhanced by sirfifer 2025 - Added cursor movement blocking
//

#include <stdio.h>
#include <sys/time.h>
#include <ApplicationServices/ApplicationServices.h>
#include <CoreFoundation/CoreFoundation.h>
#include <dispatch/dispatch.h>

#define MAJOR_VERSION  1
#define MINOR_VERSION  5
#define PATCH_VERSION  0


#define DISABLE_TAP_PB               1
#define DISABLE_DEBUG_MESSAGES       2
#define ENABLE_TAPENABLE_MESSSAGE    4
#define ENABLE_TAPDISABLE_MESSAGE    8
// 0x10 = 10 in base-16 (16 in base-10)
#define ENABLE_TAPIGNORE_MESSAGE   0x10
#define DISABLE_MOVEMENT           0x20
#define BLOCK_MOVEMENT_ENABLED     0x40
#define ENABLE_MOVEMENTIGNORE_MSG  0x80


static int mgi_flag = 0;
static long timerInterval = 1;
static long movementTimerInterval = -1; // -1 means use timerInterval
static int consecutiveDisableCount = 0;
static int consecutiveIgnoreCount = 0;
static int consecutiveMovementIgnoreCount = 0;

void PrintCurrentTime()
{
    struct timeval  tv;
    struct tm* tm_info;
    char ac_buffer[256];
    
    gettimeofday(&tv, NULL);
    
    tm_info = localtime(&tv.tv_sec);
    
    strftime(ac_buffer, sizeof(ac_buffer), "%b %d %Y %H:%M:%S", tm_info);
    
    printf("%s %dmsec",ac_buffer, tv.tv_usec/1000);
    
}

static int64_t  dispatchCount = 0;
static int64_t  movementDispatchCount = 0;

void dispatchCallBack(void * pv_context)
{
    int64_t count = (int64_t) pv_context;

    if(count == dispatchCount)
    {
        mgi_flag &= (~(DISABLE_TAP_PB));
        int countPrinted = 0;
        if((mgi_flag&DISABLE_DEBUG_MESSAGES) == 0)
        {
            if(consecutiveDisableCount && (mgi_flag&ENABLE_TAPDISABLE_MESSAGE))
            {
                printf("DisableCount %d ", consecutiveDisableCount);
                countPrinted = 1;
            }

            if(consecutiveIgnoreCount && (mgi_flag&ENABLE_TAPIGNORE_MESSAGE))
            {
                int tapCount = (consecutiveIgnoreCount/2)-1;
                if(tapCount)
                {
                    printf("IgnoreCount %d", tapCount);
                    countPrinted = 1;
                }
            }

            if(countPrinted)
            {
                printf("\n");
            }

            consecutiveDisableCount = 0;
            consecutiveIgnoreCount = 0;
            if(mgi_flag&ENABLE_TAPENABLE_MESSSAGE)
            {
                printf("Enabled Tap \n");
            }
        }
    }
}

void movementDispatchCallBack(void * pv_context)
{
    int64_t count = (int64_t) pv_context;

    if(count == movementDispatchCount)
    {
        mgi_flag &= (~(DISABLE_MOVEMENT));
        if((mgi_flag&DISABLE_DEBUG_MESSAGES) == 0)
        {
            if(consecutiveMovementIgnoreCount && (mgi_flag&ENABLE_MOVEMENTIGNORE_MSG))
            {
                printf("MovementIgnoreCount %d\n", consecutiveMovementIgnoreCount);
            }

            consecutiveMovementIgnoreCount = 0;
        }
    }
}


void dispatchDisableTap()
{
    if((mgi_flag&(DISABLE_DEBUG_MESSAGES)) == 0)
    {
        if(mgi_flag&DISABLE_TAP_PB)
        {
            ++consecutiveDisableCount;
        }
        else
        {
            if(mgi_flag&ENABLE_TAPDISABLE_MESSAGE)
            {
                printf("Disabled tap\n");
            }
        }
    }
    mgi_flag |= (DISABLE_TAP_PB);
    ++dispatchCount;
    dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_MSEC*timerInterval);
    dispatch_after_f(time, dispatch_get_main_queue(), (void *)dispatchCount, dispatchCallBack);

    // Also disable movement if the feature is enabled
    if(mgi_flag & BLOCK_MOVEMENT_ENABLED)
    {
        mgi_flag |= (DISABLE_MOVEMENT);
        ++movementDispatchCount;
        long interval = (movementTimerInterval == -1) ? timerInterval : movementTimerInterval;
        dispatch_time_t movementTime = dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_MSEC*interval);
        dispatch_after_f(movementTime, dispatch_get_main_queue(), (void *)movementDispatchCount, movementDispatchCallBack);
    }
}



CGEventRef eventCallBack(CGEventTapProxy proxy, CGEventType type, CGEventRef event, void *refcon)
{
    //if (type != kCGEventMouseMoved)
    if(type == kCGEventKeyUp)
    {
        dispatchDisableTap();
    }
    else if( (type == kCGEventLeftMouseDown)||(type == kCGEventLeftMouseUp)||(type == kCGEventRightMouseDown)||(type == kCGEventRightMouseUp) )
    {
        // if tap is disabled return NULL
        if(mgi_flag&DISABLE_TAP_PB)
        {
            if((mgi_flag&DISABLE_DEBUG_MESSAGES) == 0)
            {
                if(consecutiveIgnoreCount == 0)
                {
                    if(mgi_flag&ENABLE_TAPIGNORE_MESSAGE)
                    {
                        PrintCurrentTime();
                        printf(": Ignoring tap\n");
                    }
                }
                ++consecutiveIgnoreCount;
            }

            return NULL;
        }
    }
    else if( (mgi_flag & BLOCK_MOVEMENT_ENABLED) &&
             ((type == kCGEventMouseMoved) ||
              (type == kCGEventLeftMouseDragged) ||
              (type == kCGEventRightMouseDragged) ||
              (type == kCGEventOtherMouseDragged)) )
    {
        // if movement is disabled return NULL
        if(mgi_flag&DISABLE_MOVEMENT)
        {
            if((mgi_flag&DISABLE_DEBUG_MESSAGES) == 0)
            {
                if(consecutiveMovementIgnoreCount == 0)
                {
                    if(mgi_flag&ENABLE_MOVEMENTIGNORE_MSG)
                    {
                        PrintCurrentTime();
                        printf(": Ignoring movement\n");
                    }
                }
                ++consecutiveMovementIgnoreCount;
            }

            return NULL;
        }
    }


    return event;
}

int main(int argc, const char * argv[])
{
    CFMachPortRef eventTap;
    CFRunLoopSourceRef eventRunLoop;
    int count = 1;
    
    mgi_flag |= ENABLE_TAPIGNORE_MESSAGE;
    
    while(count < argc)
    {
        if(strcasecmp("-nodebug", argv[count]) == 0)
        {
            mgi_flag |= DISABLE_DEBUG_MESSAGES; //bitwise or
        }
        else if(strcasecmp("-time", argv[count]) == 0)
        {
            float value = 0;
            ++count;
            if(count >= argc)
            {
                exit(1);
            }
            value = strtof(argv[count], NULL);
            if(value > 0)
            {
                // converting seconds to milliseconds
                timerInterval = value*1000;
            }
        }
        else if(strcasecmp("-movementTime", argv[count]) == 0)
        {
            float value = 0;
            ++count;
            if(count >= argc)
            {
                exit(1);
            }
            value = strtof(argv[count], NULL);
            if(value > 0)
            {
                // converting seconds to milliseconds
                movementTimerInterval = value*1000;
            }
        }
        else if(strcasecmp("-blockMovement", argv[count]) == 0)
        {
            mgi_flag |= BLOCK_MOVEMENT_ENABLED;
            mgi_flag |= ENABLE_MOVEMENTIGNORE_MSG;
        }
        else if(strcasecmp("-version", argv[count]) == 0)
        {
            printf("TouchGuard v%d.%d.%d\n",MAJOR_VERSION,MINOR_VERSION,PATCH_VERSION);
        }
        else if(strcasecmp("-TapEnableMsg", argv[count]) == 0)
        {
            mgi_flag |= ENABLE_TAPENABLE_MESSSAGE;
        }
        else if(strcasecmp("-TapDisableMsg", argv[count]) == 0)
        {
            mgi_flag |= ENABLE_TAPDISABLE_MESSAGE;
        }
        count++;
    }
    
    if((mgi_flag&DISABLE_DEBUG_MESSAGES) == 0)
    {
        printf("Disable interval %ld milliSeconds\n",timerInterval);
        if(mgi_flag & BLOCK_MOVEMENT_ENABLED)
        {
            long interval = (movementTimerInterval == -1) ? timerInterval : movementTimerInterval;
            printf("Movement blocking enabled with interval %ld milliSeconds\n", interval);
        }
    }
    
    
    eventTap = CGEventTapCreate(kCGHIDEventTap, kCGHeadInsertEventTap, kCGEventTapOptionDefault, kCGEventMaskForAllEvents, eventCallBack, NULL);
    
    if(!eventTap)
        exit(1);
    
    eventRunLoop = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0);
    CFRunLoopAddSource(CFRunLoopGetCurrent(), eventRunLoop, kCFRunLoopCommonModes);
    CGEventTapEnable(eventTap, true);
    
    
    CFRunLoopRun();
    
    exit(0);
}


// Copyright 2013 Google Inc. All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#import "GoogleMediaFrameworkDemoTests.h"
#import "GMFPlayerState.h"

NSString *CONTENT_URL = @"http://rmcdn.2mdn.net/Demo/html5/output.mp4";

@implementation GoogleMediaFrameworkDemoTests {
 @private
  GMFVideoPlayer *_player;
  NSMutableArray *_eventList;
}

- (void)setUp {
  [super setUp];
  _player = [[GMFVideoPlayer alloc] init];
  [_player setDelegate:self];
  _eventList = [NSMutableArray array];
}

- (void)tearDown {
  _player = nil;
  _eventList = nil;

  [super tearDown];
}

- (void)testPlay {
  // Load URL
  [_player loadStreamWithURL:[NSURL URLWithString:CONTENT_URL]];
  [self waitForState:kGMFPlayerStateLoadingContent withTimeout:10];
  [self waitForState:kGMFPlayerStateReadyToPlay withTimeout:10];
  [self waitForState:kGMFPlayerStatePaused withTimeout:10];

  // Play stream
  [_player play];
  [self waitForState:kGMFPlayerStatePlaying withTimeout:10];

  STAssertFalse(_eventList.count, @"Unexpected events %@", _eventList);
}

- (void) waitForState:(GMFPlayerState)state withTimeout:(NSInteger)timeout {
  STAssertTrue(WaitFor(^BOOL {
      return (([_eventList count] > 0) && (_eventList[0] == [NSNumber numberWithInt:state]));
  }, timeout), @"Failed while waiting for state %@", [GoogleMediaFrameworkDemoTests stringWithState:state]);
  [self removeWaitingState:state];
}

- (void) removeWaitingState:(GMFPlayerState)state {
  [_eventList removeObject:[NSNumber numberWithInt:state]];
}

BOOL WaitFor(BOOL (^block)(void), NSTimeInterval seconds) {
  NSDate* start = [NSDate date];
  NSDate* end = [[NSDate date] dateByAddingTimeInterval:seconds];
  while (!block() && [GoogleMediaFrameworkDemoTests timeIntervalSince:start] < seconds) {
    [[NSRunLoop currentRunLoop] runMode: NSDefaultRunLoopMode
                             beforeDate: end];
  }
  return block();
}

+ (NSTimeInterval)timeIntervalSince:(NSDate*)date {
  return -[date timeIntervalSinceNow];
}

- (void) videoPlayer:(GMFVideoPlayer *)videoPlayer
  stateDidChangeFrom:(GMFPlayerState)fromState
                  to:(GMFPlayerState)toState {
  // Ignore buffering events - we can't reliable predict when they will be fired
  if (toState != kGMFPlayerStateBuffering) {
    [_eventList addObject:[NSNumber numberWithInt:toState]];
  }
}

- (void) videoPlayer:(GMFVideoPlayer *)videoPlayer
    currentMediaTimeDidChangeToTime:(NSTimeInterval)time {
  // no-op
}

- (void)videoPlayer:(GMFVideoPlayer *)videoPlayer
    bufferedMediaTimeDidChangeToTime:(NSTimeInterval)time {
  // no-op
}

+ (NSString *)stringWithState:(GMFPlayerState)state {
  switch (state) {
    case kGMFPlayerStateEmpty:
      return @"Empty";
    case kGMFPlayerStateBuffering:
      return @"Buffering";
    case kGMFPlayerStateLoadingContent:
      return @"Loading content";
    case kGMFPlayerStateReadyToPlay:
      return @"Ready to play";
    case kGMFPlayerStatePlaying:
      return @"Playing";
    case kGMFPlayerStatePaused:
      return @"Paused";
    case kGMFPlayerStateFinished:
      return @"Finished";
    case kGMFPlayerStateSeeking:
      return @"Seeking";
    case kGMFPlayerStateError:
      return @"Error";
  }
  return nil;
}

@end
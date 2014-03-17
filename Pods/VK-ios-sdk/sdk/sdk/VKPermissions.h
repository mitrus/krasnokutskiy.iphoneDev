//
//  VKPermissions.h
//
//  Copyright (c) 2013 VK.com
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of
//  this software and associated documentation files (the "Software"), to deal in
//  the Software without restriction, including without limitation the rights to
//  use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
//  the Software, and to permit persons to whom the Software is furnished to do so,
//  subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
//  FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
//  COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
//  IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
//  CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import <Foundation/Foundation.h>

static NSString *const VK_PER_NOTIFY       = @"notify";
static NSString *const VK_PER_FRIENDS      = @"friends";
static NSString *const VK_PER_PHOTOS       = @"photos";
static NSString *const VK_PER_AUDIO        = @"audio";
static NSString *const VK_PER_VIDEO        = @"video";
static NSString *const VK_PER_DOCS         = @"docs";
static NSString *const VK_PER_NOTES        = @"notes";
static NSString *const VK_PER_PAGES        = @"pages";
static NSString *const VK_PER_STATUS       = @"status";
static NSString *const VK_PER_WALL         = @"wall";
static NSString *const VK_PER_GROUPS       = @"groups";
static NSString *const VK_PER_MESSAGES     = @"messages";
static NSString *const VK_PER_NOTIFICATIONS = @"notifications";
static NSString *const VK_PER_STATS        = @"stats";
static NSString *const VK_PER_ADS          = @"ads";
static NSString *const VK_PER_OFFLINE      = @"offline";
static NSString *const VK_PER_NOHTTPS      = @"nohttps";

NSArray *parseVkPermissionsFromInteger(int permissionsValue);

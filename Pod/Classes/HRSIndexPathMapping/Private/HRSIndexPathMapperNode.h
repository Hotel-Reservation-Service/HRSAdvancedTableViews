//
//	Licensed under the Apache License, Version 2.0 (the "License");
//	you may not use this file except in compliance with the License.
//	You may obtain a copy of the License at
//
//	http://www.apache.org/licenses/LICENSE-2.0
//
//	Unless required by applicable law or agreed to in writing, software
//	distributed under the License is distributed on an "AS IS" BASIS,
//	WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//	See the License for the specific language governing permissions and
//	limitations under the License.
//

#import <Foundation/Foundation.h>

@interface HRSIndexPathMapperNode : NSObject

@property (nonatomic, assign, readonly) NSUInteger index;
@property (nonatomic, strong, readwrite) NSArray *children;

- (instancetype)initWithIndex:(NSUInteger)index condition:(BOOL(^)(void))condition;

- (void)setConditionForIndexes:(NSUInteger *)indexes depth:(NSUInteger)depth condition:(BOOL(^)(void))condition;
- (void)removeConditionForIndexes:(NSUInteger *)indexes depth:(NSUInteger)depth descendant:(BOOL)descendant;

- (void)dynamicIndexesForStaticIndexes:(NSUInteger *)indexes depth:(NSUInteger)depth;
- (void)staticIndexesForDynamicIndexes:(NSUInteger *)indexes depth:(NSUInteger)depth;

@end

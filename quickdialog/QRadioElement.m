//                                
// Copyright 2011 ESCOZ Inc  - http://escoz.com
// 
// Licensed under the Apache License, Version 2.0 (the "License"); you may not use this 
// file except in compliance with the License. You may obtain a copy of the License at 
// 
// http://www.apache.org/licenses/LICENSE-2.0 
// 
// Unless required by applicable law or agreed to in writing, software distributed under
// the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF 
// ANY KIND, either express or implied. See the License for the specific language governing
// permissions and limitations under the License.
//

#import "QBindingEvaluator.h"

@implementation QRadioElement {
    QSection *_internalRadioItemsSection;
}
static UIColor* _defaultValueColor = nil;
@synthesize selected = _selected;
@synthesize values = _values;
@synthesize items = _items;
@synthesize placeholder = _placeholder;
@synthesize textAlignment = _textAlignment;

+ (UIColor*) getDefaultValueColor {
    return _defaultValueColor;
}
+(void) setDefaultValueColor:(UIColor*)color {
    _defaultValueColor = [color copy];
}
- (void)createElements {
    _sections = nil;
    _internalRadioItemsSection = [[QSection alloc] init];
    _parentSection = _internalRadioItemsSection;

    [self addSection:_parentSection];

    for (NSUInteger i=0; i< [_items count]; i++){
        [_parentSection addElement:[[QRadioItemElement alloc] initWithIndex:i RadioElement:self]];
    }
}

-(void)setItems:(NSArray *)items {
    _items = items;
    [self createElements];
}

-(NSObject *)selectedValue {
    return [_values objectAtIndex:(NSUInteger) _selected];
}

-(void)setSelectedValue:(NSObject *)aSelected {
    if ([aSelected isKindOfClass:[NSNumber class]]) {
    _selected = [(NSNumber *)aSelected integerValue];
    } else {
    _selected = [_values indexOfObject:aSelected];
    }
}


- (QRadioElement *)initWithItems:(NSArray *)stringArray selected:(NSInteger)selected {
    self = [self initWithItems:stringArray selected:selected title:nil];
    return self;
}


- (QRadioElement *)initWithDict:(NSDictionary *)valuesDictionary selected:(int)selected title:(NSString *)title {
    self = [self initWithItems:valuesDictionary.allKeys selected:(NSUInteger) selected];
    _values = valuesDictionary.allValues;
    self.title = title;
    return self;
}


-(void)setSelectedItem:(id)item {
    if (self.items==nil)
        return;
    self.selected = [self.items indexOfObject:item];
}

-(id)selectedItem {
    if (self.items == nil || [self.items count]<self.selected)
        return nil;

    return [self.items objectAtIndex:(NSUInteger) self.selected];
}

- (QRadioElement *)initWithItems:(NSArray *)stringArray selected:(NSInteger)selected title:(NSString *)title {
    self = [super init];
    if (self!=nil){
        self.items = stringArray;
        self.selected = selected;
        self.title = title;
    }
    return self;
}

- (void)selected:(QuickDialogTableView *)tableView controller:(QuickDialogController *)controller indexPath:(NSIndexPath *)path {
    if (self.sections==nil)
            return;

    [controller displayViewControllerForRoot:self];
}


- (UITableViewCell *)getCellForTableView:(QuickDialogTableView *)tableView controller:(QuickDialogController *)controller {

    NSString *selectedValue = nil;
    if (_selected >= 0 && _selected <_items.count)
        selectedValue = [[_items objectAtIndex:(NSUInteger) _selected] description];
    self.value = selectedValue;
    QEntryTableViewCell *cell = (QEntryTableViewCell *) [super getCellForTableView:tableView controller:controller];
    if ([QRadioElement getDefaultValueColor] == nil) {
        [QRadioElement setDefaultValueColor:cell.detailTextLabel.textColor];
    }
//    if (self.title == NULL){
//        cell.textField.text = selectedValue;
//        cell.detailTextLabel.text = nil;
//        cell.imageView.image = nil;
//    } else {
//        cell.textLabel.text = _title;
//        cell.textField.text = selectedValue;
//        cell.imageView.image = nil;
//    }
//    cell.textField.textAlignment = UITextAlignmentRight;
//    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
//    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
//    cell.textField.userInteractionEnabled = NO;
    if ((self.isTitleHidden || self.title == nil) && self.textAlignment == UITextAlignmentLeft) {
        cell.detailTextLabel.text = nil;
        cell.textLabel.font = self.font;

        if (self.valueLineBreakPolicy == QValueLineBreakPolicyWrap) {
            cell.textLabel.numberOfLines = 0;
        }
        if (self.placeholder != nil && [selectedValue length ] == 0 ) {
            cell.textLabel.text = self.placeholder;
            cell.textLabel.textColor = [UIColor lightGrayColor];
        } else {
            cell.textLabel.text = selectedValue;
            cell.textLabel.textColor = [QRadioElement getDefaultValueColor];
        }
    } else {
        if (self.placeholder != nil && [selectedValue length ] == 0 ) {
            cell.detailTextLabel.text = self.placeholder;
            cell.detailTextLabel.textColor = [UIColor lightGrayColor];
        } else {
            cell.detailTextLabel.textColor = [QRadioElement getDefaultValueColor];
        }
    }
    return cell;
}

-(void)setSelected:(NSInteger)aSelected {
    _selected = aSelected;

}

- (CGFloat)getRowHeightForTableView:(QuickDialogTableView *)tableView {
    if (self.valueLineBreakPolicy == QValueLineBreakPolicyWrap) {
        NSString *selectedValue = nil;
        if (_selected >= 0 && _selected <_items.count)
            selectedValue = [[_items objectAtIndex:(NSUInteger) _selected] description];

        CGSize constraint = CGSizeMake(tableView.frame.size.width-(tableView.root.grouped ? 40.f : 20.f), 20000);
        CGSize  size= [selectedValue sizeWithFont:self.font constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
        CGFloat predictedHeight = size.height + 20.0f;
        if (self.title!=nil || !self.isTitleHidden)
            predictedHeight+=30;
        CGFloat height = [super getRowHeightForTableView:tableView];
        return (height >= predictedHeight) ? height : predictedHeight;        
    } else {
        return [super getRowHeightForTableView:tableView];
    }
}

- (void)fetchValueIntoObject:(id)obj {
	if (_key==nil)	
		return;

    if (_selected < 0 || _selected >= (_values != nil ? _values : _items).count)
        return;

    if (_values==nil){
        [obj setValue:[NSNumber numberWithInt:_selected] forKey:_key];
    } else {
        [obj setValue:[_values objectAtIndex:(NSUInteger) _selected] forKey:_key];
    }
}


@end

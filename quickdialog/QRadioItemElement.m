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

#import "QuickDialogTableView.h"
#import "QSection.h"
#import "QRootElement.h"
#import "QRadioItemElement.h"

@implementation QRadioItemElement

- (QRadioItemElement *)initWithIndex:(NSUInteger)index RadioElement:(QRadioElement *)radioElement {
    self = [super init];
    _radioElement = radioElement;
    _index = index;
    _title = [[radioElement.items objectAtIndex:_index] description];
    return self;
}

- (QRadioItemElement *)initWithIndex:(NSUInteger)index RadioSection:(QRadioSection *)section {
    self = [super init];
    _radioSection = section;
    _index = index;
    _title = [[_radioSection.items objectAtIndex:_index] description];
    return self;
}

- (UITableViewCell *)getCellForTableView:(QuickDialogTableView *)tableView controller:(QuickDialogController *)controller {
    UITableViewCell *cell = [super getCellForTableView:tableView controller:controller];
    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    NSInteger selectedIndex = _radioElement==nil? _radioSection.selected : _radioElement.selected;
    cell.accessoryType = selectedIndex == _index ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    if (_radioElement.valueLineBreakPolicy == QValueLineBreakPolicyWrap) {
        cell.textLabel.numberOfLines = 0;
    }
    return cell;
}

- (void)selected:(QuickDialogTableView *)tableView controller:(QuickDialogController *)controller indexPath:(NSIndexPath *)indexPath {
    [super selected:tableView controller:controller indexPath:indexPath];

    NSInteger selectedIndex = _radioElement==nil? _radioSection.selected : _radioElement.selected;

    if (_index != selectedIndex) {
        UITableViewCell *oldCell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:selectedIndex inSection:indexPath.section]];
        oldCell.accessoryType = UITableViewCellAccessoryNone;
        [oldCell setNeedsDisplay];

        UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
        selectedCell.accessoryType = UITableViewCellAccessoryCheckmark;
    }

    if (_radioElement!= nil)
    {
        _radioElement.selected = _index;
        [_radioElement handleElementSelected:controller];
        tableView.userInteractionEnabled = NO;

        [NSTimer scheduledTimerWithTimeInterval:0.3
            target:controller
            selector:@selector(popToPreviousRootElement)
            userInfo:nil
            repeats:NO];

    }
    else if (_radioSection!=nil)
    {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];

        _radioSection.selected = _index;
        if (_radioSection.onSelected) {
            _radioSection.onSelected();
        }
    }
}

- (CGFloat)getRowHeightForTableView:(QuickDialogTableView *)tableView {
    if (_radioElement.valueLineBreakPolicy == QValueLineBreakPolicyWrap) {
        CGSize constraint = CGSizeMake(tableView.frame.size.width-(tableView.root.grouped ? 40.f : 20.f), 20000);
        CGSize  size= [_title sizeWithFont:self.font constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
        CGFloat predictedHeight = size.height + 20.0f;
        CGFloat height = [super getRowHeightForTableView:tableView];
        return (height >= predictedHeight) ? height : predictedHeight;        
    } else {
        return [super getRowHeightForTableView:tableView];
    }
}


@end
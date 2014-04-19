#import <Foundation/Foundation.h>
#import <Nu/Nu.h>

@implementation NSString (AgentCSV)

- (NSArray *) agent_CSVRows {
    NSMutableArray *rows = [NSMutableArray array];

    // Get newline character set
    NSMutableCharacterSet *newlineCharacterSet = (id)[NSMutableCharacterSet whitespaceAndNewlineCharacterSet];
    [newlineCharacterSet formIntersectionWithCharacterSet:[[NSCharacterSet whitespaceCharacterSet] invertedSet]];

    // Characters that are important to the parser
    NSMutableCharacterSet *importantCharactersSet = (id)[NSMutableCharacterSet characterSetWithCharactersInString:@",\""];
    [importantCharactersSet formUnionWithCharacterSet:newlineCharacterSet];

    // Create scanner, and scan string
    NSScanner *scanner = [NSScanner scannerWithString:self];
    [scanner setCharactersToBeSkipped:nil];
    while ( ![scanner isAtEnd] ) {        
        BOOL insideQuotes = NO;
        BOOL finishedRow = NO;
        NSMutableArray *columns = [NSMutableArray arrayWithCapacity:10];
        NSMutableString *currentColumn = [NSMutableString string];
        while ( !finishedRow ) {
            NSString *tempString;
            if ( [scanner scanUpToCharactersFromSet:importantCharactersSet intoString:&tempString] ) {
                [currentColumn appendString:tempString];
            }

            if ( [scanner isAtEnd] ) {
                if ( ![currentColumn isEqualToString:@""] ) [columns addObject:currentColumn];
                finishedRow = YES;
            }
            else if ( [scanner scanCharactersFromSet:newlineCharacterSet intoString:&tempString] ) {
                if ( insideQuotes ) {
                    // Add line break to column text
                    [currentColumn appendString:tempString];
                }
                else {
                    // End of row
                    if ( ![currentColumn isEqualToString:@""] ) [columns addObject:currentColumn];
                    finishedRow = YES;
                }
            }
            else if ( [scanner scanString:@"\"" intoString:NULL] ) {
                if ( insideQuotes && [scanner scanString:@"\"" intoString:NULL] ) {
                    // Replace double quotes with a single quote in the column string.
                    [currentColumn appendString:@"\""]; 
                }
                else {
                    // Start or end of a quoted string.
                    insideQuotes = !insideQuotes;
                }
            }
            else if ( [scanner scanString:@"," intoString:NULL] ) {  
                if ( insideQuotes ) {
                    [currentColumn appendString:@","];
                }
                else {
                    // This is a column separating comma
                    [columns addObject:currentColumn];
                    currentColumn = [NSMutableString string];
                    [scanner scanCharactersFromSet:[NSCharacterSet whitespaceCharacterSet] intoString:NULL];
                }
            }
        }
        if ( [columns count] > 0 ) [rows addObject:columns];
    }

    return rows;
}

- (NSString *) agent_CSVEscapedString
{    
    NSString *escapedString = self;
    
    BOOL containsSeperator = !NSEqualRanges([self rangeOfString:@","], NSMakeRange(NSNotFound, 0));
    BOOL containsQuotes = !NSEqualRanges([self rangeOfString:@"\""], NSMakeRange(NSNotFound, 0));
    BOOL containsLineBreak = !NSEqualRanges([self rangeOfString:@"\n"], NSMakeRange(NSNotFound, 0));

    if (containsQuotes) {
        escapedString = [escapedString stringByReplacingOccurrencesOfString:@"\"" withString:@"\"\""];
    }
    
    if (containsSeperator || containsLineBreak) {
        escapedString = [NSString stringWithFormat:@"\"%@\"", escapedString];
    }
    
    return escapedString;
}
@end

@implementation NSArray (AgentCSV)

- (NSString *) agent_CSVRowRepresentation
{
    NSMutableString * string = [NSMutableString string];
    BOOL firstColumn = YES;
    for(id column in self) {
        NSString *columnString;
        if ([column isKindOfClass:[NSString class]]) {
            columnString = column;               
        } else {        
            columnString = [column stringValue];
        }
        NSString *separator = !firstColumn ? @"," : @"";        
	[string appendFormat:@"%@%@", separator, [columnString agent_CSVEscapedString]];
        firstColumn = NO;
    }
    [string appendString:@"\n"];
	return string;
}

- (NSString *) agent_CSVRepresentation 
{
	NSMutableString *string = [NSMutableString string];
	for (id row in self) {
		[string appendString:[row agent_CSVRowRepresentation]];
	}
	return string;
}

@end

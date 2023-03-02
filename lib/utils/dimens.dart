import 'package:flutter/material.dart';

//Screen Dimensions
Size? screenSize;

// Spacing Constant
const spacingTiny = 5.0;
const spacingXSmall = 7.5;
const spacingSmall = 10.0;
const spacingMedium = 15.0;
const spacingLarge = 20.0;
const spacingXLarge = 25.0;
const spacingXXLarge = 30.0;
const spacingXXMLarge = 35.0;
const spacingXXXLarge = 40.0;
const spacingXXXSLarge = 50.0;
const spacingXXXXLarge = 75.0;

// Font Size Constant
const labelFontSize = 14.0;
const headerTitleSize = 24.0;
const buttonLabelFontSize = 18.0;
const tabBarTitle = 15.0;

//Local Camera View
const horizontalWidth = 110.0;
const verticalLength = 139.0;

// Font Weight Constant
const fontWeightRegular = FontWeight.w400;

//To Get Dynamic Screen Size
void getScreenSize(BuildContext context) {
  screenSize = MediaQuery.of(context).size;
}

// Image Size Constant
const imageMTiny = 35.0;
const imageXLarge = 170.0;

//Icon Size Constant
const smallIconSize = 20.0;

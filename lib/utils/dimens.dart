import 'package:flutter/material.dart';

//Screen Dimensions
Size screenSize;

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
const spacingXXXMLarge = 60.0;
const spacingXXXXLarge = 75.0;

// Font Size Constant
const smallLabelFontSize = 12.0;
const labelFontSize = 14.0;
const headerTitleSizeSmall = 21.0;
const headerTitleSize = 24.0;
const descriptionFontSize = 16.0;
const buttonLabelFontSize = 18.0;
const fontSizeDescription = 16.0;
const fontSizeTitle = 30.0;
const tabBarTitle = 15.0;

// Font Weight Constant
const fontWeightExtraLight = FontWeight.w200;
const fontWeightLight = FontWeight.w300;
const fontWeightRegular = FontWeight.w400;
const fontWeightMedium = FontWeight.w500;
const fontWeightSemiBold = FontWeight.w600;
const fontWeightBold = FontWeight.w700;
const fontWeightExtraBold = FontWeight.w800;

void getScreenSize(BuildContext context) {
  screenSize = MediaQuery.of(context).size;
}

// Image Size Constant
const imageSTiny = 20.0;
const imageXTiny = 15.0;
const imageTiny = 25.0;
const imageMTiny = 35.0;
const imageSmall = 45.0;
const imageMSmall = 60.0;
const imageMedium = 80.0;
const imageLarge = 100.0;
const imageXLarge = 170.0;
const icCameraSize = 29.0;

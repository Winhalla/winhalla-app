import 'package:flutter/cupertino.dart';

class InheritedTextStyle extends InheritedWidget{
  const InheritedTextStyle({
    Key? key,
    required this.kHeadline0,
    required this.kHeadline1,
    required this.kHeadline2,
    required this.kBodyText1,
    required this.kBodyText1bis,
    required this.kBodyText1Roboto,
    required this.kBodyText2,
    required this.kBodyText2bis,
    required this.kBodyText3,
    required this.kBodyText4,
    required Widget child,
  }) : super(key: key, child: child);

  final TextStyle kHeadline0;
  final TextStyle kHeadline1;
  final TextStyle kHeadline2;
  final TextStyle kBodyText1;
  final TextStyle kBodyText1bis;
  final TextStyle kBodyText1Roboto;
  final TextStyle kBodyText2;
  final TextStyle kBodyText2bis;
  final TextStyle kBodyText3;
  final TextStyle kBodyText4;

  static InheritedTextStyle of(BuildContext context) {
    final InheritedTextStyle? result = context.dependOnInheritedWidgetOfExactType<InheritedTextStyle>();
    assert(result != null, 'No InheritedTextStyle found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(InheritedTextStyle old) => false;
}
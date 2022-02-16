import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:winhalla_app/config/themes/dark_theme.dart';
import 'package:winhalla_app/utils/get_uri.dart';
import 'package:winhalla_app/utils/order_progress_painter.dart';
import 'package:winhalla_app/utils/user_class.dart';
import 'package:winhalla_app/widgets/coin.dart';
import 'package:winhalla_app/widgets/custom_expansion_tile.dart';
import 'package:winhalla_app/widgets/info_dropdown.dart';
import 'package:winhalla_app/widgets/inherited_text_style.dart';
import 'package:winhalla_app/widgets/popup_shop.dart';

// This is bc we can't use context.read<User>() in the future field of FutureBuilder
const List<String> kOrdersStatuses = [
  "Sending steam friend request",
  "Accept the friend request",
  "Awaiting Steam's delay for gifts",
  "Delivered"
];

const List<String> kPaypalStatuses = [
  "Delivering...",
  "Delivered."
];

Future<dynamic> getShopData(BuildContext context) async {
  var userData = context.read<User>();
  return await userData.initShopData();
}

class Shop extends StatefulWidget {
  const Shop({Key? key}) : super(key: key);

  @override
  State<Shop> createState() => _ShopState();
}

class _ShopState extends State<Shop> {
  String _selectedTab = "shop";
  void switchTab(String tabName) {
    setState(() {
      if (tabName == "shop") {
        _selectedTab = "shop";
      } else {
        _selectedTab = "orders";
      }
    });
  }

  String statusToText(int status, String mode){
    String statusFound;
    try{
      statusFound = mode == "paypal" ? kPaypalStatuses[status] : kOrdersStatuses[status];
    }catch(e){
      statusFound = "Delivering...";
    }
    return statusFound;
  }

  @override
  Widget build(BuildContext context) {
    context.read<User>().setKeyFx(switchTab, "switchShopTab");
    if (_selectedTab == "shop") {
      return Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Column(
          children: [
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    "Balance:",
                    style: InheritedTextStyle.of(context).kHeadline1,
                  ),
                ),
                const SizedBox(
                  width: 25,
                ),
                Consumer<User>(
                  builder: (context, user, _) {
                    return Coin(nb: ((user.value["user"]["coins"]*10).round()/10).toString(),);
                  }
                )
              ],
            ),
            const SizedBox(
              height: 50,
            ),
            FutureBuilder(
                future: getShopData(context),
                builder: (context, AsyncSnapshot<dynamic> res) {
                  if (!res.hasData) {
                    return Column(
                      children: [
                        const Center(child: CircularProgressIndicator()),
                        SizedBox(
                          width: 100.w,
                          height: 100.h,
                        )
                      ],
                    );
                  }
                  return Column(
                    children: [
                      ShopItem(
                        cost: res.data["featuredItem"]["cost"],
                        itemId: res.data["featuredItem"]["id"],
                        name: res.data["featuredItem"]["name"],
                        nickname: res.data["featuredItem"]["nickname"],
                        platforms: res.data["featuredItem"]["platforms"],
                      ),
                      const SizedBox(
                        height: 60,
                      ),
                      PaypalCredit(
                          cost: res.data["paypalData"]["cost"],
                          itemId: res.data["paypalData"]["id"]),
                      const SizedBox(
                        height: 60,
                      ),
                      ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemBuilder: (context, int index) {
                          var item = res.data["items"][index];
                          return Container(
                            margin: EdgeInsets.only(top: index == 0 ? 0 : 40.0),
                            child: ShopItem(
                              itemId: item["id"],
                              cost: item["cost"],
                              name: item["name"],
                              nickname: item["nickname"],
                              platforms: item["platforms"],
                            ),
                          );
                        },
                        itemCount: res.data["items"].length,
                      ),
                      SizedBox(
                        height: 14.h,
                      )
                    ],
                  );
                }),
          ],
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                "Orders:",
                style: InheritedTextStyle.of(context).kHeadline1,
              ),
            ),
          SizedBox(height: 4.h,),
          FutureBuilder(future: context.read<User>().callApi.get("/commands"), builder: (BuildContext context, AsyncSnapshot res){
            if(!res.hasData || res.data["successful"] == false) {
              return Column(
                children: [
                  const CircularProgressIndicator(),
                  SizedBox(height: 100.h, width: 100.w,)
                ],
              );
            }
            if(res.data["data"].length == 0){
              return Padding(
                padding: EdgeInsets.only(top: 2.h),
                child: Center(
                  child: Text(
                    "Your orders and their status will appear here once you order them.",
                    style: InheritedTextStyle.of(context).kBodyText2.apply(color: kText80),
                  ),
                ),
              );
            }
            return ListView.builder(
                itemCount: res.data["data"].length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, int i){
              var item = res.data["data"][i];
              // Computes if a smaller font is needed for the pink text
              final textPainter = TextPainter(
                text: TextSpan(
                    text: statusToText(item["state"], item["type"] ?? ""), style: InheritedTextStyle.of(context).kBodyText1bis.apply(color: kEpic)),
                textDirection: TextDirection.ltr,
              );
              textPainter.layout(
                  maxWidth:
                  35.w);
              List lines = textPainter.computeLineMetrics();
              bool needsSmallFont = false;
              if(lines.length > 1) needsSmallFont = true;

              Function? rebuildTitle;
              bool isExpanded = false;
              return Container(
                margin: EdgeInsets.only(bottom: 3.h),
                child: CustomExpansionTile(
                  onExpansionChanged: (bool expandStatus){
                    isExpanded = expandStatus;
                    if(rebuildTitle != null){
                      rebuildTitle!();
                    }
                  },
                  children: [
                    ListTile(
                      minVerticalPadding: 0,
                      contentPadding: EdgeInsets.zero,
                      title: Container(
                        height: item["type"] == "paypal" ? 12.6.h : 21.h,
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.vertical(bottom: Radius.circular(15)),
                          color: kBackgroundVariant,
                        ),
                        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Padding(
                            padding: EdgeInsets.only(top: 4.2.h, left: 9.w),
                            child: CustomPaint(
                              painter: OrderProgressPainter(context, item["state"], item["type"] ?? ""),
                            ),
                          ),
                          /*Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            for (String i in kOrdersStatuses)
                              Padding(
                                padding: EdgeInsets.only(top: 1.h, bottom: 1.h, left: 15.w),
                                child: Text(i, style: InheritedTextStyle.of(context).kBodyText4.apply(fontSizeFactor: 0.9)),
                              )
                          ],)*/
                        ],),
                      ),
                    )
                  ],
                  title: StatefulBuilder(
                    builder: (context, setState) {
                      void rebuild(){
                        setState((){});
                      }
                      rebuildTitle = rebuild;
                      return Container(
                        constraints: BoxConstraints(maxHeight: 11.h),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.vertical(
                            top: const Radius.circular(15),
                            bottom: isExpanded ? Radius.zero : const Radius.circular(15),
                          ),
                          color: kBackgroundVariant,
                        ),
                        child: Row(children: [
                          if (item["type"] != "paypal") Container(
                            decoration: BoxDecoration(
                                color: kBackgroundVariant,
                                borderRadius: BorderRadius.only(
                                    topLeft: const Radius.circular(15),
                                    bottomLeft: const Radius.circular(15),
                                    bottomRight: isExpanded ? const Radius.circular(15) : Radius.zero
                                ),
                                image: DecorationImage(
                                    image: NetworkImage(
                                        apiUrl+"/assets/shopItems/${item["product"].toLowerCase().replaceAll(" ", "-")}.jpg"),
                                    fit: BoxFit.fill)
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                SizedBox(
                                  height: 10.h,width: 35.w,
                                ),
                              ],
                            ),
                          ) else Container(
                            width: 32.w,
                            height: 8.8.h,
                            margin: EdgeInsets.only(top: 1.1.h, bottom: 1.1.h, left: 3.w),
                            padding: EdgeInsets.symmetric(horizontal: 0.5.w),
                            decoration: const BoxDecoration(
                              color: kBackground,
                              borderRadius: BorderRadius.all(Radius.circular(15)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Image.asset(
                                    "assets/images/icons/paypal_logo_big.png",
                                    height: 5.h,
                                    // width: 15.w,
                                ),
                                Text("${item['number']}€", style: InheritedTextStyle.of(context).kBodyText1bis.apply(color: kText80),)
                              ],
                            ),
                          ),
                          Container(
                            width: 48.5.w,
                            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                              Row(
                                children: [
                                  SizedBox(
                                    width:30.w,
                                    child: Text(
                                      statusToText(item["state"], item["type"] ?? ""),
                                      overflow: TextOverflow.ellipsis,
                                      style: needsSmallFont
                                          ? InheritedTextStyle.of(context).kBodyText4.apply(color: kEpic)
                                          : InheritedTextStyle.of(context).kBodyText1bis.apply(color: kEpic),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 10.5.w,
                                    child: Icon(
                                      Icons.expand_more,
                                      color: kEpic,
                                      size: InheritedTextStyle.of(context).kHeadline2.fontSize,
                                    ),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: EdgeInsets.only(top: 0.25.h),
                                child: Row(
                                  // crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text("Claimed: ", style: InheritedTextStyle.of(context).kBodyText3.apply(color: kText80, fontSizeFactor: 0.8)),
                                    Text(formatToLocalDateyMd(DateTime.fromMillisecondsSinceEpoch(item["date"])), style: InheritedTextStyle.of(context).kBodyText4.apply(color: kText)),
                                  ],
                                ),
                              )
                            ],),
                          )
                        ],),
                      );
                    }
                  ),
                ),
              );
            });
          }),
          SizedBox(height: 8.h,)

        ],),
      );
    }
  }
}

class ShopItem extends StatelessWidget {
  final String name;
  final int itemId;
  final String nickname;
  final int cost;
  final platforms;
  const ShopItem(
      {Key? key,
      required this.cost,
      required this.name,
      required this.nickname,
      required this.itemId,
      required this.platforms})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            Opacity(
              opacity: 0.7,
              child: Container(
                decoration: BoxDecoration(
                    color: kBackgroundVariant,
                    borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(20),
                        topLeft: Radius.circular(20)),
                    image: DecorationImage(
                        image: NetworkImage(
                            apiUrl+"/assets/shopItems/${name.toLowerCase().replaceAll(" ", "-")}.jpg"),
                        fit: BoxFit.cover)),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: const [
                    SizedBox(
                      height: 200,
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(21),
              decoration: const BoxDecoration(
                  color: kBackgroundVariant,
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20))),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: .9),
                    child: Text(
                      nickname,
                      style: InheritedTextStyle.of(context).kHeadline2,
                    ),
                  ),
                  Price(
                    cost: cost.toString(),
                    itemId: itemId,
                  )
                ],
              ),
            ),
          ],
        ),
        platforms.length < 2 && platforms[0] == "steam" ? Positioned(
            left: 4.w,
            top: 1.5.h,
            child: Container(
              padding:
                  EdgeInsets.symmetric(horizontal: 4.0.w, vertical: 1.45.h),
              decoration: const BoxDecoration(
                color: kBackground,
                borderRadius: BorderRadius.all(Radius.circular(15)),
              ),
              child: Row(
                children: [
                  Image.asset(
                    "assets/images/icons/steam.png",
                    height: 24,
                    color: kText95,
                  ),
                  SizedBox(
                    width: 2.75.w,
                  ),
                  Text("Only",
                      style: InheritedTextStyle.of(context)
                          .kBodyText2
                          .apply(color: kText95, fontSizeFactor: 0.85)),
                ],
              ),
            )
        ) : Container()
        /*Positioned(
          top: 10,
          right: 20,
          child: GestureDetector(
            onTap: (){
              context.read<User>().setItemGoal(itemId);
            },
            child: Container(
              padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(14),color: kEpic),
              child: const Text("Set As Goal",style: InheritedTextStyle.of(context).kBodyText4,),
            ),
          ),
        ),*/
      ],
    );
  }
}

class PaypalCredit extends StatefulWidget {
  final int cost;
  final int itemId;
  const PaypalCredit({Key? key, required this.cost, required this.itemId})
      : super(key: key);

  @override
  _PaypalCreditState createState() => _PaypalCreditState();
}

class _PaypalCreditState extends State<PaypalCredit> {
  List<Map<String, dynamic>> items = [
    {"amount": 2.5, "displayName": "2.5€"},
    {"amount": 5, "displayName": "5€"},
    {"amount": "custom", "displayName": "Custom"}
  ];

  dynamic amount = 1;
  TextEditingController textAmount = TextEditingController(text: "1");

  @override
  void initState() {
    textAmount.addListener(_addressControllerListener);
    super.initState();
  }

  void _addressControllerListener() {
    try {
      setState(() {
        amount = double.parse(textAmount.text);
      });
    } catch (e) {
      setState(() {
        amount = textAmount.text.toString();
      });
    }
  }

  @override
  void dispose() {
    textAmount.removeListener(_addressControllerListener);
    super.dispose();
  }

  int _selectedItem = 0;

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Container(
        padding: const EdgeInsets.fromLTRB(36, 20, 36, 15),
        child: Builder(builder: (context) {
          // Iterate over the items array to make a horizontal equivalent of listview.builder
          List<Widget> itemsWidget = [];
          for (int i = 0; i < items.length; i++) {
            itemsWidget.add(
              GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  setState(() {
                    _selectedItem = i;
                  });
                },
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 300),
                  style: InheritedTextStyle.of(context).kBodyText1.apply(
                      color: i == _selectedItem ? kText : kText80),
                  child: Text(
                  items[i]["displayName"],
                  
                ),
              )),
            );
          }
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: itemsWidget),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  for (int i = 0; i < itemsWidget.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(left:3.5,right: 22.0),
                      child: AnimatedOpacity(
                        curve: Curves.easeInOut,
                        duration: const Duration(milliseconds: 225),
                        opacity: i == _selectedItem ? 1 : 0,
                        child: Container(
                          width: 23,
                          height: 3,
                          color: kPrimary,
                        )
                      ),
                    ),
                ],
              ),
            ],
          );
        }),
        decoration: const BoxDecoration(
          color: kBlack,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
      ),
      Container(
        padding: const EdgeInsets.fromLTRB(30, 20, 30, 20),
        child: items[_selectedItem]["amount"] != "custom"
            ? Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 3.0),
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4.0),
                          child: Image.asset(
                            "assets/images/icons/paypal_logo_big.png",
                            height: 35,
                            width: 35,
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Text(
                          "Paypal",
                          style: InheritedTextStyle.of(context).kBodyText1,
                        ),
                      ],
                    ),
                  ),
                  Price(
                    cost:
                        "${(widget.cost * items[_selectedItem]["amount"]).toInt()}",
                    itemId: widget.itemId,
                    amount: items[_selectedItem]["amount"],
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    decoration: BoxDecoration(
                        color: kBlack, borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.fromLTRB(20, 0, 15, 0),
                    child: SizedBox(
                      width: 35,
                      child: TextField(
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(4),
                        ],
                        controller: textAmount,
                        decoration: InputDecoration(
                          hintText: "1",
                          suffixText: "€",
                          suffixStyle: InheritedTextStyle.of(context).kBodyText3,
                          border: InputBorder.none,
                        ),
                        keyboardType: TextInputType.number,
                        style: InheritedTextStyle.of(context).kBodyText3,
                      ),
                    ),
                  ),
                  Padding(
                    child: Transform.rotate(
                      angle: 180 * pi / 180,
                      child: const Icon(
                        Icons.arrow_right_alt,
                        size: 40,
                        color: kText,
                      ),
                    ),
                    padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                  ),
                  Price(
                      cost: amount.runtimeType == String
                          ? "..."
                          : "${(widget.cost * amount).toInt()}",
                      itemId: widget.itemId,
                      amount: amount.runtimeType == String ? null : amount),
                ],
              ),
        decoration: const BoxDecoration(
          color: kBackgroundVariant,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
      ),
    ]);
  }
}

class Price extends StatelessWidget {
  final String cost;
  final int itemId;
  final num? amount;
  const Price({Key? key, required this.cost, required this.itemId, this.amount})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        var userInfo = context.read<User>().value["user"];
        try {
          if (userInfo["coins"] < double.parse(cost)) {
            showInfoDropdown(
              context,
              kRed,
              "Not enough coins",
            );
            return;
          } else if (int.parse(cost) == 0) {
            showInfoDropdown(
              context,
              kRed,
              "Select at least 1\$",
            );
            return;
          }
        } on FormatException {
          return;
        }
        var result = await showDialog(
            context: context,
            builder: (context) => PopupWidget(
                context, userInfo["email"], itemId,
                amount: amount));
        if (result == null) return;
        if (result["success"] == true) {
          showInfoDropdown(context, kGreen, "Gift sent!",
              body: Text(
                "Check your mails",
                style: Theme.of(context)
                    .textTheme
                    .bodyText2
                    ?.merge(InheritedTextStyle.of(context).kBodyText2.apply(color: kText)),
              ));
          context.read<User>().addCoins(-int.parse(cost));
        }
      },
      child: Coin(
        nb:cost,
        color:kText,
        bgColor: kPrimary,
        fontSize: 26,
        borderRadius: 14,
        padding: EdgeInsets.fromLTRB(5.w, 9.5, 5.w, 6.5),
      )
    );
  }
}

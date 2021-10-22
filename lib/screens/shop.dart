import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:winhalla_app/config/themes/dark_theme.dart';
import 'package:winhalla_app/utils/getUri.dart';
import 'package:winhalla_app/utils/userClass.dart';
import 'package:http/http.dart' as http;
import 'package:winhalla_app/widgets/infoDropdown.dart';
import 'package:winhalla_app/widgets/popupshop.dart';

Future<dynamic> getShopData(BuildContext context) async {
  var userData = context.read<User>();
  if (userData.shop == null) {
    try {
      var shopData = jsonDecode((await http.get(getUri("/shop"))).body);

      var featuredItem = shopData.firstWhere((e) => e["state"] == 0);
      var paypalItem = shopData.firstWhere((e) => e["type"] == "paypal");
      List<dynamic> items = shopData.where((e) => (e["type"] != "paypal") && (e["state"] != 0)).toList();

      items.sort((a, b) => a["state"].compareTo(b["state"]) as int);

      userData.setShopDataTo({"items": items, "featuredItem": featuredItem, "paypalData": paypalItem});
      return {"items": items, "featuredItem": featuredItem, "paypalData": paypalItem};
    } catch (e) {}
  } else {
    return userData.shop;
  }
}

class Shop extends StatelessWidget {
  const Shop({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Text(
              "Balance:",
              style: kHeadline1,
            ),
            SizedBox(
              width: 20,
            ),
            Container(
              decoration: BoxDecoration(color: kBackgroundVariant, borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.fromLTRB(22, 9, 22, 6),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 3),
                    child: Image.asset(
                      "assets/images/coin.png",
                      height: 30,
                      width: 30,
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Consumer<User>(builder: (context, user, _) {
                    return Text(
                      user.value["user"]["coins"].toString(),
                      style: kBodyText1.apply(color: kPrimary),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 50,
        ),
        FutureBuilder(
            future: getShopData(context),
            builder: (context, AsyncSnapshot<dynamic> res) {
              if (!res.hasData) return Center(child: CircularProgressIndicator());
              return Column(
                children: [
                  ShopItem(
                    cost: res.data["featuredItem"]["cost"],
                    itemId: res.data["featuredItem"]["id"],
                    name: res.data["featuredItem"]["name"],
                    nickname: res.data["featuredItem"]["nickname"],
                  ),
                  const SizedBox(
                    height: 60,
                  ),
                  PaypalCredit(
                      cost: res.data["paypalData"]["cost"],
                      itemId: res.data["paypalData"]["id"]
                  ),
                  const SizedBox(
                    height: 60,
                  ),
                  ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
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
                        ),
                      );
                    },
                    itemCount: res.data["items"].length,
                  ),
                ],
              );
            }),
      ],
    );
  }
}

class ShopItem extends StatelessWidget {
  final String name;
  final int itemId;
  final String nickname;
  final int cost;

  const ShopItem({Key? key, required int this.cost, required String this.name, required String this.nickname, required this.itemId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Opacity(
          opacity: 0.7,
          child: Container(
            decoration: BoxDecoration(
                color: kBackgroundVariant,
                borderRadius: BorderRadius.only(topRight: Radius.circular(20), topLeft: Radius.circular(20)),
                image: DecorationImage(
                    image:
                        AssetImage("assets/images/shopItems/${name.toLowerCase().replaceAll(" ", "-")}.jpg"),
                    fit: BoxFit.cover)),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                SizedBox(
                  height: 200,
                ),
              ],
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(20, 21, 20, 21),
          decoration: BoxDecoration(
              color: kBackgroundVariant,
              borderRadius:
                  BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20))),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Text(
                nickname,
                style: TextStyle(color: kText, fontSize: 35),
              ),
              SizedBox(
                width: 20,
              ),
              Price(cost: cost.toString(),itemId: itemId  ,)
            ],
          ),
        ),
      ],
    );
  }
}

class PaypalCredit extends StatefulWidget {
  final int cost;
  final int itemId;
  const PaypalCredit({Key? key, required this.cost,required this.itemId}) : super(key: key);

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
    try{
      setState(() {
        amount = int.parse(textAmount.text);;
      });
    }catch(e){
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
        padding: const EdgeInsets.fromLTRB(30, 25, 30, 25),
        child: Builder(builder: (context) { // Iterate over the items array to make a horizontal equivalent of listview.builder
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
                child: Text(
                  items[i]["displayName"],
                  style: kBodyText1.apply(color: i == _selectedItem ? kText : kText80),
                ),
              ),
            );
          }
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: itemsWidget,
          );
        }),
        decoration: BoxDecoration(
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
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4.0),
                        child: Image.asset(
                          "assets/images/icons/paypal_logo.png",
                          height: 35,
                          width: 35,
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      const Text(
                        "Paypal",
                        style: TextStyle(fontSize: 30, color: kText),
                      ),
                    ],
                  ),
                  Price(
                    cost:"${(widget.cost * items[_selectedItem]["amount"]).toInt()}",
                    itemId: widget.itemId,amount: amount.runtimeType == String?null:amount,
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    decoration: BoxDecoration(color: kBlack, borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.fromLTRB(20, 0, 15, 0),
                    child: SizedBox(
                      width: 35,
                      child: TextField(
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(2),
                        ],
                        controller: textAmount,
                        decoration: const InputDecoration(
                          hintText: "1",
                          suffixText: "€",
                          suffixStyle: kBodyText3, border: InputBorder.none,
                        ),
                        keyboardType: TextInputType.phone,
                        style: kBodyText3,
                      ),
                    ),
                  ),
                  const Padding(
                    child: Icon(
                      Icons.arrow_right_alt,
                      size: 40,
                      color: kText,
                    ),
                    padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                  ),
                  Price(
                    cost:amount.runtimeType == String?"...":"${(widget.cost * amount).toInt()}",
                    itemId:widget.itemId,
                    amount:amount.runtimeType == String?null:amount
                  ),
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
  final int? amount;
  const Price({Key? key,required this.cost,required this.itemId,this.amount}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {

        var userInfo = context.read<User>().value["user"];
        try {
          if(userInfo["coins"] < int.parse(cost)) {
            showInfoDropdown(context, kRed, "Not enough coins",);
            return;
          }
        } on FormatException {
          return;
        }
        var result =
            await showDialog(context: context, builder: (context) => PopupWidget(context,userInfo["email"],itemId,amount: amount));
        if(result == null) return;
        if(result["success"] == true) {
          showInfoDropdown(context, kGreen, "Gift sent!",
              body: Text(
                "check your mails",
                style: Theme.of(context).textTheme.bodyText2?.merge(TextStyle(color: kText, fontSize: 24)),
              ));
          context.read<User>().addCoins(-int.parse(cost));
        }
      },
      child: Container(
        decoration: BoxDecoration(color: kPrimary, borderRadius: BorderRadius.circular(14)),
        padding: const EdgeInsets.fromLTRB(16, 9, 16, 6),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 2.5),
              child: Image.asset(
                "assets/images/coin.png",
                color: kText,
                height: 30,
                width: 30,
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            Text(
              cost,
              style: kBodyText2.apply(fontFamily: "Bebas neue"),
            ),
          ],
        ),
      ),
    );
  }
}


import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mongol/mongol.dart';
import 'package:zmongol/Component/MongolToolTip.dart';
import 'package:zmongol/Controller/KeyboardController.dart';
import 'package:zmongol/Controller/StyleController.dart';
import 'package:zmongol/Model/CustomizableText.dart';

import '../Component/MongolFonts.dart';
import '../Controller/TextController.dart';
import '../Keyboard/MongolKeyboard.dart';
import 'Share.dart';

///photoWithText
class EditorPage extends StatefulWidget {
  final bool editWithImage;
  final String? text;
  EditorPage({required this.editWithImage, this.text});

  @override
  _EditorPageState createState() => _EditorPageState();
}

class _EditorPageState extends State<EditorPage> {
  bool overlayOffsetIsInitialed = false;
  FocusNode _focusNode = FocusNode();
  int cursorOffset = 0;
  bool editable = true;
  int layoutTime = 0;

  //double canvasWidth = 300.0;
  //   double canvasHeight = 480.0;
  List teinIlgalCands = [
    'ᡭᡧ',
    'ᡬᡬᡧ',
    'ᡳ',
    "ᡭᡳ",
    "ᡳᡪᢝ",
    "ᡬᡬᡪᢝ",
    "ᡳᡪᡧ",
    "ᡬᡬᡪᡧ",
    'ᢘᡳ',
    'ᢙᡳ',
    'ᡬᡫ',
    'ᡫ',
    'ᡥᢚᡧ',
    "ᢘᡪᡫ",
    "ᡭᡭᡧ",
    "ᢘᡪᡱᡱᡪᡧ",
    "ᢘᡪᢊᡪᡧ",
    "ᢙᡪᡱᡱᡪᡧ",
    "ᢙᡪᢊᡪᡧ",
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: true,
      child: Stack(
        children: [
          Scaffold(
            appBar: AppBar(
              title: Text(
                'Z ᢌᡭᡪᢊᡱᡱᡭᢐ',
                style: TextStyle(fontFamily: MongolFonts.haratig),
                ),
              centerTitle: true,
              backgroundColor: Colors.indigo,
              actions: [
                GetBuilder<KeyboardController>(
                  id: 'cands',
                  builder: (ctr) {
                    return IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: ctr.text.isNotEmpty
                          ? () {
                              Get.dialog(MongolAlertDialog(
                                title: MongolText('ᡥᡪᡪᢊᡪᡪᡪᢞᡪᡪᡳ',
                                    // title: Text('Alert',
                                    style: TextStyle(color: Colors.red, fontSize: 32, fontFamily: MongolFonts.haratig)),
                                content: MongolText('ᡴᡭᡬᢋᡭᡧ ᡫ ᡥᡪᢞᢚᡬᡪᡪᡳ ᡭᡳ ᡓ',
                                    // content: Text('Confirm Delete?',
                                    style: TextStyle(color: Colors.black, fontSize: 20, fontFamily: MongolFonts.haratig)),
                                actions: <Widget>[
                                  TextButton(
                                    child: MongolText(
                                      'ᡴᡭᢚᡪᡰᡨ',
                                      // 'cancel',
                                      style: TextStyle(color: Colors.black, fontSize: 20, fontFamily: MongolFonts.haratig),
                                    ),
                                    onPressed: () {
                                      Get.back();
                                    },
                                  ),
                                  TextButton(
                                    child: MongolText(
                                      'ᡥᡪᢞᢚᡬᡰᡨ',
                                      // 'delete',
                                      style: TextStyle(color: Colors.red, fontSize: 20, fontFamily: MongolFonts.haratig),
                                    ),
                                    onPressed: () {
                                      ctr.delelteAll();
                                      Get.back();
                                    },
                                  ),
                                ],
                              ));
                            }
                          : null,
                    );
                  },
                ),
                GetBuilder<KeyboardController>(
                  id: 'cands',
                  builder: (ctr) => IconButton(
                      icon: Icon(Icons.done),
                      onPressed: ctr.text.isNotEmpty
                          ? () {
                              ctr.setLatin('', isMongol: false);
                              // NOTE: if we're editing an existing text box, go back to previous screen
                              if (widget.text != null) {
                                Get.back(result: ctr.text);
                                return;
                              }
                              if (widget.editWithImage) {
                                Get.back(result: ctr.text);
                              } else {
                                CustomizableText text = CustomizableText(tag: DateTime.now().microsecondsSinceEpoch.toString(), text: ctr.text, editable: true);
                                Get.to(SharePage(text));
                              }
                            }
                          : null),
                )
              ],
            ),
            body: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Expanded(
                  child: Container(
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            //padding: EdgeInsets.only(left: 8),
                            color: Colors.grey.shade400,
                            child: Center(
                              child: GetBuilder<StyleController>(
                                builder: (styleCtr) => Container(
                                  color: Colors.white,
                                  padding: const EdgeInsets.all(4),
                                  child: GetBuilder<TextStyleController>(
                                    builder: (ctr) {
                                      print('now fontsize = ${ctr.style.fontSize}');
                                      return GetBuilder<KeyboardController>(
                                        builder: (kbCtr) {
                                          if (widget.text != null) {
                                            kbCtr.textEditingController.text = widget.text!;
                                          } else {
                                            kbCtr.textEditingController.text = '';
                                          }
                                          return MongolTextField(
                                            scrollPadding: const EdgeInsets.only(),
                                            autofocus: true,
                                            showCursor: true,
                                            readOnly: true,
                                            focusNode: _focusNode,
                                            expands: true,
                                            maxLines: null,
                                            controller: kbCtr.textEditingController,
                                            decoration: InputDecoration(
                                              contentPadding: EdgeInsets.only(),
                                              border: InputBorder.none,
                                            ),
                                            // keyboardType: MongolKeyboard.inputType,
                                            textInputAction:
                                            TextInputAction.newline,
                                            //keyboardType: TextInputType.multiline,
                                            style: TextStyle(fontSize: ctr.style.fontSize, fontFamily: MongolFonts.haratig),
                                            //像平常一样设置键盘输入类型一样将Step1编写的inputType传递进去
                                          );
                                        },
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                              border: Border(
                                  right: BorderSide(
                                      color: Colors.grey.shade200,
                                      width: 1 /
                                          MediaQuery.of(context)
                                              .devicePixelRatio))),
                        ),
                        Container(
                          width: 50,
                          child: Column(
                            children: [
                              GetBuilder<TextStyleController>(
                                  builder: (ctr) => IconButton(
                                      icon: Stack(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(4.0),
                                            child: Text('A',
                                                style: TextStyle(fontSize: 18)),
                                          ),
                                          Positioned(right: 0, child: Text('+'))
                                        ],
                                      ),
                                      onPressed: () {
                                        ctr.increaseFontSize();
                                      })),
                              GetBuilder<TextStyleController>(
                                builder: (ctr) => IconButton(
                                    icon: Stack(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(4.0),
                                          child: Text(
                                            'A',
                                            style: TextStyle(fontSize: 18),
                                          ),
                                        ),
                                        Positioned(right: 0, child: Text('-'))
                                      ],
                                    ),
                                    onPressed: () {
                                      ctr.decreaseFontSize();
                                    }),
                              ),
                              MongolTooltip(
                                message:
                                    'ᡳᡬᢚᡬᢑᢊᡪᡨ  ᡭᡧ  ᢚᡬᡬᡨ ᡫ ᢘᡪᢊᡪᢊᢔᡫ ᢔᡬᢑᢛᡬᢋᡭᢑᢋᡭ',
                                showDuration: Duration(seconds: 3),
                                child: GetBuilder<KeyboardController>(
                                  builder: (ctr) => IconButton(
                                      icon: RotatedBox(
                                          quarterTurns: 1,
                                          child: Icon(Icons.skip_previous)),
                                      onPressed: () {
                                        ctr.cursorMoveUp();
                                      }),
                                ),
                              ),
                              MongolTooltip(
                                message:
                                    'ᡳᡬᢚᡬᢑᢊᡪᡨ  ᡭᡧ  ᢚᡬᡬᡨ ᡫ ᢘᡭᢞᡭᡪᡪᢔᡫ ᢔᡬᢑᢛᡬᢋᡭᢑᢋᡭ',
                                showDuration: Duration(seconds: 3),
                                child: GetBuilder<KeyboardController>(
                                  builder: (ctr) => IconButton(
                                      icon: RotatedBox(
                                          quarterTurns: 3,
                                          child: Icon(Icons.skip_previous)),
                                      onPressed: () {
                                        ctr.cursorMoveDown();
                                      }),
                                ),
                              ),
                              MongolTooltip(
                                message: 'ᡸᡪᡱᡱᡭᢑᡪᡪᡳ ',
                                child: GetBuilder<KeyboardController>(
                                  builder: (ctr) => IconButton(
                                      icon: Icon(Icons.copy),
                                      onPressed: () {
                                        ClipboardData data =
                                            new ClipboardData(text: ctr.text);
                                        if (ctr.text != null) {
                                          //增加个判断防止复制null，避免闪退
                                          Clipboard.setData(data);
                                          Get.snackbar('Successfully copied ',
                                              'the content is copied to your phone',
                                              snackPosition:
                                                  SnackPosition.BOTTOM);
                                        }
                                      }),
                                ),
                              ),
                              MongolTooltip(
                                message: 'ᡯᡪᡱᡱᡪᡪᡪᡳ ',
                                child: GetBuilder<KeyboardController>(
                                  builder: (ctr) => IconButton(
                                      icon: Icon(Icons.paste),
                                      onPressed: () async {
                                        ClipboardData? data =
                                            await Clipboard.getData(
                                                Clipboard.kTextPlain);
                                        if (data != null && data.text != null) {
                                          ctr.addText(data.text!);
                                        }
                                        //之前忘了添加到文本里
                                      }),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                GetBuilder<KeyboardController>(
                    id: 'cands',
                    builder: (ctr) {
                      print('teinIlgalCands :${teinIlgalCands.length}');
                      print('latin.value.length :${ctr.latin.value.length}');
                      return Material(
                        color: Colors.grey.shade100,
                        elevation: 3,
                        child: Obx(
                          () {
                            late double candsHeight;

                            if (ctr.latin.value.length >= 7) {
                              var len = ctr.latin.value.length;
                              candsHeight =
                                  len * ScreenUtil().setHeight(6.0) + 75;
                              print('candsHeight $candsHeight');
                            } else if (ctr.latin.value.length < 7) {
                              candsHeight = ScreenUtil().setHeight(90.0);
                            }
                            return Container(
                              width: MediaQuery.of(context).size.width,
                              height: candsHeight,
                              // color: Colors.grey.shade100,
                              child: ctr.latin.value.isEmpty
                                  ? Stack(
                                      children: [
                                        Padding(
                                            padding:
                                                const EdgeInsets.only(top: 8.0),
                                            child: ListView.builder(
                                                scrollDirection:
                                                    Axis.horizontal,
                                                itemCount:
                                                    teinIlgalCands.length,
                                                itemBuilder: (context, int i) {
                                                  var e = teinIlgalCands[i];
                                                  return InkWell(
                                                    onTap: () {
                                                      ctr.enterAction(e);
                                                    },
                                                    child: Container(
                                                      height: 100,
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .symmetric(
                                                                horizontal: 4),
                                                        child: MongolText(
                                                          e,
                                                          style: TextStyle(
                                                              fontFamily:
                                                                  'haratig',
                                                              fontSize: 24),
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                })),
                                      ],
                                    )
                                  : Stack(
                                      children: [
                                        Container(
                                          width:
                                              MediaQuery.of(context).size.width,
                                          height: candsHeight,
                                          child: Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 8.0),
                                              child: ListView.builder(
                                                  scrollDirection:
                                                      Axis.horizontal,
                                                  itemCount: ctr.cands.length,
                                                  itemBuilder:
                                                      (context, int i) {
                                                    var e = ctr.cands[i];
                                                    return InkWell(
                                                      onTap: () {
                                                        ctr.enterAction(e);
                                                      },
                                                      child: Container(
                                                        height: candsHeight,
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .symmetric(
                                                                  horizontal:
                                                                      4),
                                                          child: MongolText(
                                                            e,
                                                            style: TextStyle(
                                                                fontFamily:
                                                                    'haratig',
                                                                fontSize: 24),
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                  })),
                                        ),
                                        Positioned(
                                            bottom: 0,
                                            left: 150,
                                            child: Container(
                                              padding: EdgeInsets.all(2),
                                              // color: Colors.white,
                                              child: Text(
                                                ctr.latin.value,
                                                style: TextStyle(
                                                    fontSize: 22,
                                                    color: Colors.black),
                                              ),
                                            )),
                                      ],
                                    ),
                            );
                          },
                        ),
                      );
                    }),
                MongolKeyboard()
              ],
            ),
          ),
        ],
      ),
    );
  }
}

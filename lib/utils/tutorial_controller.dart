import 'package:flutter/material.dart';
import 'package:winhalla_app/config/themes/dark_theme.dart';
import 'package:winhalla_app/utils/services/secure_storage_service.dart';
class TutorialController extends ChangeNotifier{
    int status = 0;
    BuildContext context;
    late OverlayEntry overlayEntry;
    bool finished = false;
    List widgets = [
        Positionned(
            top: 100,
            left: 50,
            right : 50,
            child: Text("Test", style: TextStyle(fontFamily:'Roboto condensed', fontSize:30)),
        ),
        Positionned(
            top: 300,
            left: 20,
            right : 20,
            child: Text("Test2", style: TextStyle(fontFamily:'Roboto condensed', fontSize:30)),
        ),
        Positionned(
            top: 200,
            left: 50,
            right: 50,
            child: Text("Test3", style: TextStyle(fontFamily:'Roboto condensed', fontSize:30)),
        ),
    ];
    Widget currentTextWidget = widgets[status];

    TutorialController(this.context) async {
        dynamic tutorialStep = secureStorage.read(key:"tutorialStep");
        dynamic tutorialFinished = secureStorage.read(key:"tutorialFinished");
        tutorialStep = await tutorialStep;
        tutorialFinished = await tutorialFinished;
        if(tutorialFinished == "true")
            endTutorial();
        else {
            status = tutorialStep == null ? 0 : tutorialStep;
            currentTextWidget = widgets[status];
        }
    }

    void summon(){
        OverlayEntry overlayEntry = OverlayEntry(
            builder: (_){
                return StatefulBuilder(
                    builder: (ctxt, setState){
                        var tutorialData = Provider.of<TutorialController>(context)
                        return Stack(
                            children:[
                                currentTextWidget,
                                Row(
                                    mainAxisAlignment:MainAxisAlignment.spaceBetween,
                                    children:[
                                        TextButton(
                                            onPressed:()=>tutorialData.previous(),
                                            child: Text(
                                                "Back",
                                                style:TextStyle(fontFamily:'Roboto condensed', fontSize:30, color:kText80),
                                            ),
                                        ),
                                        TextButton(
                                            onPressed:()=>tutorialData.next(),
                                            child: Text(
                                                "Next",
                                                style:TextStyle(fontFamily:'Roboto condensed', fontSize:30, color:kOrange),
                                                ),
                                        )
                                    ]
                                )
                            ]
                        )
                    }
                )                    
            }
        );
        Overlay.of(context)?.insert(
            overlayEntry
        );
    }

    void next(){
        status ++;
        notifyListeners();
    }
    
    void previous(){
        status -= 1;
        notifyListeners();
    }
    
    void endTutorial(){
        overlayEntry.remove();
        finished = true;
        notifyListeners();
    }
}
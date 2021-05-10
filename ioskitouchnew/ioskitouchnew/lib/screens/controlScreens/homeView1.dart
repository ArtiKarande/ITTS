/*
 * Created by Mahendra Phule in the year of 2019.
 * Copyright (c) 2019 Mahendra Phule. All rights reserved.
 */

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ioskitouchnew/common/sharedPreferece/SharedKeys.dart';
import 'package:ioskitouchnew/common/sharedPreferece/SharedPreferneces.dart';
import 'package:ioskitouchnew/models/building.dart';
import 'package:ioskitouchnew/screens/preferenceScreens/addElementScreen.dart';
import 'package:ioskitouchnew/themeManager.dart';

import '../../FlutterApp.dart';

/// [HomeView] Displays the grid of [Home]s.
/// With this view users can interact to choose which [Home] they want to control.
/// It uses [childList] of [Building] data set to form the view.
class HomeView1 extends StatefulWidget {
  static final String tag = 'home1';
  /// Change event notifiers used here to notify changes in data/ui.
  /// Other classes can listen to these notifiers to take actions accordingly.

  /// Scene change notifies if there is change in any view and ui needs to be updated.
  static ValueNotifier<bool> sceneChangeNotifier = ValueNotifier(true);

  /// Data change notifies if there is change in data set of the application.
  static ValueNotifier<bool> dataChangeNotifier = ValueNotifier(true);

  /// Makes Object of [HomeView] class.
  ///
  /// Also adds replicate listeners to [sceneChangeNotifier] and [dataChangeNotifier] from state class {[_HomeViewState]}.
  /// Actual data/view change happens in state class these changes need to be propagated up in the display hierarchy.
  /// These propagation is done by these replication of event listeners.
  HomeView1() {
    // Replication of change events on [_HomeViewState.sceneChangeNotifier].
    _HomeViewState.sceneChangeNotifier.addListener(() =>
        (sceneChangeNotifier.value = _HomeViewState.sceneChangeNotifier.value));

    // Replication of change events on [_HomeViewState.dataChangeNotifier].
    _HomeViewState.dataChangeNotifier.addListener(() =>
        (dataChangeNotifier.value = _HomeViewState.dataChangeNotifier.value));
  }

  /// Creating state class to manage states.
  @override
  State<StatefulWidget> createState() => _HomeViewState();
}

/// [_HomeViewState] is a state class of [HomeView].
/// It creates and maintains UI and its different states for [HomeView].
///
/// When user interacts with [HomeView], data-set or UI might need be updated,
/// [_HomeViewState] notifies these updates in data-set or UI.
class _HomeViewState extends State<HomeView1> {
  /// Scene change notifies if there is change in any view and ui needs to be updated.
  static ValueNotifier<bool> sceneChangeNotifier = ValueNotifier(true);

  /// Data change notifies if there is change in data set of the application.
  static ValueNotifier<bool> dataChangeNotifier = ValueNotifier(true);

  int themeVal;
  SharedPreference pref = new SharedPreference();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    pref.getString(SharedKey().THEME_VALUE).then((val) {
      if (val != null) {
        setState(() {
          themeVal = int.parse(val);
          FlutterApp.themeValue = int.parse((val));
        });
        print("themeVal hime::$themeVal");
      }
    });
  //  pref.putInt(SharedKey().INDEX_KEY, 0);
  }

  /// Method to build UI with grid of [Home]s.
  @override
  Widget build(BuildContext context) {
    var shortestSide = MediaQuery.of(context).size.shortestSide;
    var useMobileLayout = shortestSide < 600;

    /// orientation landscape
    var hasDetailPage =
        MediaQuery.of(context).orientation == Orientation.landscape;

    // Grid view of [Home]s 2 in one row.
    // Other spacing parameters just for the clean and simple look.
    return Building.isDatabaseUpdating.value == true
        ?new Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).primaryColor,
            title: new Text("Add Home"),
          ),
      body: OrientationBuilder(
        builder: (context, orientation) {
          return orientation == Orientation.portrait
              ? gridView()
              : gridViewLand();
        },
      )  ,
    ): new Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: new Text("Add Home"),
      ),
      body: OrientationBuilder(
        builder: (context, orientation) {
          return orientation == Orientation.portrait
              ? gridView()
              : gridViewLand();
        },
      ) ,
    );
  }

  Widget gridView(){
    return GridView.count(
      crossAxisCount: 3,
      childAspectRatio: 1.0,
      padding: const EdgeInsets.all(10.0),
      mainAxisSpacing: 5.0,
      crossAxisSpacing: 5.0,
      children: makeGridView(),
    );
  }

  Widget gridViewLand(){
    return GridView.count(
      crossAxisCount: 8,
      childAspectRatio: 1.0,
      padding: const EdgeInsets.all(5.0),
      mainAxisSpacing: 5.0,
      crossAxisSpacing: 5.0,
      children: makeGridView(),
    );
  }

  /// Making list of widgets to be displayed in grid view.
  /// It generates list of view elements for every [Home] of [Building].
  List<Widget> makeGridView() {
    List<Widget> list = List();
    // Adding every [Home] of [Building].
    for (int index = 0;
    index < Building.getInstance().childList.length;
    index++) {
      if(Building.getInstance().childList[index].name!="My Home") {
        list.add(makeGridCell(index));
      }else{
        list.add(Material(
          child: InkWell(
            onTap: () {
              AddElementScreen.type = 0;
              Navigator.of(context).pushNamed(AddElementScreen.tag);
              dataChangeNotifier.value = !dataChangeNotifier.value;
            },
            splashColor: Colors.blueGrey,
            child: LayoutBuilder(builder: (ct, cr) {
              return new Container(
                width:100.0,
                height: 100.0,
                child: item(),
              );
            }),
          ),
        ));
      }
    }
    // ADD button card to invoke preference screen to add [Device].
    // If users taps on this card, user is routed to preference screen after confirmation.
    list.add(Material(
      child: InkWell(
        onTap: () {
          AddElementScreen.type = 0;
          Navigator.of(context).pushNamed(AddElementScreen.tag);
          dataChangeNotifier.value = !dataChangeNotifier.value;
        },
        splashColor: Colors.blueGrey,
        child: LayoutBuilder(builder: (ct, cr) {
          return item();
        }),
      ),
    ));

    return list;
  }

  Widget item(){
    return new Container(
      alignment: Alignment.center,
      child: new Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          verticalDirection: VerticalDirection.down,
          children: <Widget>[
            Icon(Icons.add, size: 64),
            Center(
                child: Text(
                  'Add Home',
                  style: TextStyle(fontSize: 10.0),
                )),
          ],
        ),
      ),
      decoration: themeVal == 2
          ? new BoxDecoration(border: new Border.all(color: Colors.amber))
          : new BoxDecoration(
          border: new Border.all(color: Colors.yellowAccent)),
    );
  }

  /// Single Element in grid,
  /// made with index pointing to [Home] in [childList] of [Building].
  ///
  /// It is a card like element which has different functionality for user interactions like tap, long press.
  Material makeGridCell(int index) {
    return Material(
//      shape: BeveledRectangleBorder(
//          borderRadius: BorderRadius.only(bottomRight: Radius.circular(30.0))),
      // elevation: 15.0,
      // color: Colors.black,
      //shadowColor: Colors.black,
      child: InkWell(
        // On tap of the [Home] view we set that [Home] as selected one,
        // And navigate UI to next tab so that user can interact with [Rooms]s.
        // Selected [Home] is marked with different color.
        onTap: () {
          setState(() => (Building.getInstance().indexChildList = index));
          sceneChangeNotifier.value = !sceneChangeNotifier.value;
        },
        splashColor: Colors.blueGrey,
        child: LayoutBuilder(builder: (ct, cr) {
          return new Container(
            width: 100.0,
            height: 100.0,
            alignment: Alignment.center,
            child: new Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                verticalDirection: VerticalDirection.down,
                children: <Widget>[
                  //   ThemeManager.iconList[Building.getInstance().getHomeAtIndex(index).iconIndex].icon,
                  Icon(
                    ThemeManager
                        .iconListForHome[Building.getInstance()
                        .getHomeAtIndex(index)
                        .iconIndex]
                        .icon,
                    size: 42,
                    color: themeVal == 2
                        ? (index == Building.getInstance().indexChildList)
                        ? ThemeManager.colorSelected
                        : ThemeManager.boxUnselectedColor
                        : (index == Building.getInstance().indexChildList)
                        ? ThemeManager.colorSelected
                        : ThemeManager.unselectedColor,
                  ),
                  Center(
                      child: Text(
                        Building.getInstance().getHomeAtIndex(index).name,
                        style: TextStyle(fontSize: 10.0),
                      )),
                ],
              ),
            ),
            decoration: themeVal == 2
                ? new BoxDecoration(border: new Border.all(color: Colors.amber))
                : new BoxDecoration(
                border: new Border.all(color: Colors.yellowAccent)),
          );
        }),
      ),
    );
  }

  /// Alert dialog to change the icon of the [Home].
  Future<Null> changeIcon(int index) async {
    // Close previous alert dialog.
    Navigator.of(context).pop();

    // All icon options for [Home] are displayed to user,
    // user can select one of those icons to set new icon to the selected [Home],
    // or just select cancel to abort the icon change.
    return showDialog<Null>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Choose icon'),
          actions: <Widget>[
            FlatButton(
              child: Text('Cancel', style: TextStyle(color:themeVal==2? Colors.black:Colors.white)),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
          content: Container(
            width: MediaQuery.of(context).size.width * .7,
            child: GridView.count(
              crossAxisCount: 4,
              childAspectRatio: 1.0,
              shrinkWrap: true,
              padding: const EdgeInsets.all(4.0),
              mainAxisSpacing: 4.0,
              crossAxisSpacing: 4.0,
              children: ThemeManager.iconListForHome.reversed.map((T) {
                return Material(
                  shape: BeveledRectangleBorder(
                      borderRadius: BorderRadius.only(
                          bottomRight: Radius.circular(10.0))),
                  elevation: 5.0,
                  shadowColor: Colors.black,
                  color: themeVal==2? Colors.black:Colors.grey,
                  child: InkWell(
                    onTap: () {
                      setState(() => (Building.getInstance()
                              .getHomeAtIndex(index)
                              .iconIndex =
                          ThemeManager.iconListForHome.indexOf(T)));
                      dataChangeNotifier.value = !dataChangeNotifier.value;
                      Building.getInstance().updateDB();
                      Navigator.of(context).pop();
                    },
                    splashColor: Colors.blueGrey,
                    child: LayoutBuilder(builder: (ct, cr) {
                      return Icon(
                        T.icon,
                        size: cr.biggest.height - 4,
                        color: ThemeManager.unselectedColor,
                      );
                    }),
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  /// Alert dialog to change the name of the [Home].
  Future<Null> changeName(int index) async {
    // Close previous alert dialog.
    Navigator.of(context).pop();

    // Text editing UI is displayed to user.
    // User can change name of the [Home] and press Rename to change name,
    // or just select cancel to abort the icon change.
    final c = TextEditingController();
    final TextField tf = TextField(
      autofocus: true,
      controller: c,
      decoration: InputDecoration(
          labelText: 'Rename Home to: ', hintText: 'eg. My Home'),
    );
    c.text = Building.getInstance().getHomeAtIndex(index).name;
    return showDialog<Null>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Rename : ' +
              '"' +
              Building.getInstance().getHomeAtIndex(index).name +
              '"'),
          content: tf,
          actions: <Widget>[
            FlatButton(
              child: Text('Rename',style: TextStyle(color:themeVal==2? Colors.black:Colors.white)),
              onPressed: () {
                setState(() => (Building.getInstance()
                    .getHomeAtIndex(index)
                    .name = c.text));
                dataChangeNotifier.value = !dataChangeNotifier.value;
                Building.getInstance().updateDB();
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text('Cancel', style: TextStyle(color:themeVal==2? Colors.black:Colors.white)),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  /// Alert dialog to delete the [Home] from [Building].
  Future<Null> delete(int index) async {
    // Close previous alert dialog.
    Navigator.of(context).pop();

    // Confirmation dialog to user to confirm about deleting [Home] from [Building].
    // [Home] is deleted from [Building] if user confirms or user can abort by clicking on cancel.
    return showDialog<Null>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Delete',style: TextStyle(color:themeVal==2? Colors.black:Colors.white)),
          content: Text('"' +
              Building.getInstance().getHomeAtIndex(index).name +
              '" will be deleted permenantly.'),
          actions: <Widget>[
            FlatButton(
              child: Text('Yes, Delete'),
              onPressed: () {
                setState(() {
                  Building.getInstance().childList.removeAt(index);
                  Building.getInstance().indexChildList = 0;
                  dataChangeNotifier.value = !dataChangeNotifier.value;
                });
                Building.getInstance().updateDB();
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text('Cancel', style: TextStyle(color:themeVal==2? Colors.black:Colors.white)),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  /// Alert dialog to add a [Room] to selected [Home].
  Future<Null> addChild(int index) async {
    // Close previous alert dialog.
    Navigator.of(context).pop();

    // Confirmation dialog to take user to the preference screen to add a [Room] to the [Home] pointed by the [index].
    // User is routed to preference screen after confirmation to add [Room].
    return showDialog<Null>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Redirecting'),
          content:
              Text('You will be redirected to settings to add/edit rooms.'),
          actions: <Widget>[
            FlatButton(
              child: Text('Confirm'),
              onPressed: () {
                Navigator.of(context).pop();
                setState(() => (Building.getInstance().indexChildList = index));
                dataChangeNotifier.value = !dataChangeNotifier.value;
                AddElementScreen.type = 1;
                Navigator.of(context).pushNamed(AddElementScreen.tag);
              },
            ),
            FlatButton(
              child: Text('Cancel', style: TextStyle(color: Colors.white)),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }
}

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:quiz/quizpage.dart';
import 'package:quiz/styles.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // this function is called before the build so that
    // and now we return the FutureBuilder to load and decode JSON
    return FutureBuilder(
      future: DefaultAssetBundle.of(context)
          .loadString("assets/examplecsvjson.json", cache: false),
      builder: (context, snapshot) {
        Map<String, dynamic> mydata = json.decode(snapshot.data.toString()); //JSON data
        if (mydata == null) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else {
          return MainPage(mydata: mydata);
        }
      },
    );
  }
}

class MainPage extends StatefulWidget {
  final Map<String, dynamic> mydata;
  MainPage({Key key, @required this.mydata}) : super(key: key);
  @override
  _MainPageState createState() => _MainPageState(mydata);
}

class _MainPageState extends State<MainPage> {
  final Map<String, dynamic> mydata;
  _MainPageState(this.mydata);

  Map<String, dynamic> questiondata; //real quiz data
  String timevalue = "30"; // set the initial value of countdown selection
  String randomvalue = "no"; // set the initial value of randomizing into "no"
  String areavalue = "all"; // set the initial value of category into "all category"
  String questionvalue = "2"; // set the initial number of questions into 2 questions
  int maxquestion = 1; // initial value of max questions
  List questionnumbers;

  // this fucntion is called when the page is loaded
  @override
  void initState() {
    this.maxquestion = mydata.length;
    this.questiondata = mydata;
    var array = [];
    for(int i=1;i<=mydata.length;i++){
      array.add(i.toString());
    }
    questionnumbers = array.toSet().toList();
    super.initState();
  }

  // overriding the setstate function to be called only if mounted
  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  // category dropdown widget
  Widget dropdownmenuitem(String text, String value) {
    return DropdownMenuItem<String>(
      child: Row(
        children: <Widget>[
          Text(text),
        ],
      ),
      value: value,
    );
  }

  // overriding the main page
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DefaultTabController(
        length: 1,
        child: Scaffold(
          body: TabBarView(
            children: <Widget>[
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    height: 90,
                    color: Theme.of(context).cursorColor,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Settings',
                              style: settingsStyle,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 6,
                    child: Container(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              const Padding(
                                padding: EdgeInsets.fromLTRB(8.0, 48.0, 8.0, 8.0),
                                child: Text(
                                  'Max Questions :',style: settingTextStyle,
                                ),
                              ),
                              Expanded(
                                  child: Padding(
                                padding: EdgeInsets.fromLTRB(8.0, 48.0, 8.0, 8.0),
                                child: Text(
                                  '${this.maxquestion.toString()}',
                                  style: TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                              )),
                            ],
                          ),
                          Row(
                            children: <Widget>[
                              const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  'Category:',style: settingTextStyle
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.all(8.0),
                                child: DropdownButton<String>(
                                  items: [
                                    dropdownmenuitem('All', 'all'),
                                    dropdownmenuitem('1', '1'),
                                    dropdownmenuitem('2', '2'),
                                    dropdownmenuitem('3', '3'),
                                    dropdownmenuitem('4', '4'),
                                    dropdownmenuitem('5', '5'),
                                  ],
                                  isExpanded: false,
                                  onChanged: (String value) {
                                    setState(() {
                                      areavalue = value;
                                      if (value == 'all') {
                                        questiondata = mydata;
                                        maxquestion = mydata.length;
                                        questionvalue = "1";
                                      } else {
                                        questiondata = new Map();
                                        questionnumbers = new List();
                                        var numbers = [];
                                        int n = 1;
                                        mydata.forEach((key, data) {
                                          if (data['area'] == value) {
                                            questiondata[n.toString()] = data;
                                            numbers.add(key);
                                            n++;
                                          }
                                        });
                                        questionnumbers = numbers.toSet().toList();
                                        maxquestion = questiondata.length;
                                        questionvalue = "1";
                                      }
                                    });
                                  },
                                  value: areavalue,
                                  underline: Container(
                                    decoration: const BoxDecoration(
                                        border: Border(
                                            bottom:
                                                BorderSide(color: Colors.grey))),
                                  ),
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: <Widget>[
                              const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  'N. of Questions:',style: settingTextStyle,
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.all(8.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    new NumberPicker.horizontal(
                                        listViewHeight: 30,
                                        initialValue: int.parse(questionvalue),
                                        minValue: 1,
                                        maxValue: maxquestion,
                                        onChanged: (newValue) => setState(() =>
                                            questionvalue = newValue.toString())),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: <Widget>[
                              const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Icon(Icons.timer),
                              ),
                              const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  'Time per Question:',style: settingTextStyle,
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.only(top: 8.0),
                                child: new NumberPicker.horizontal(
                                    listViewHeight: 30,
                                    initialValue: int.parse(timevalue),
                                    minValue: 10,
                                    maxValue: 180,
                                    step: 10,
                                    onChanged: (newValue) => setState(
                                        () => timevalue = newValue.toString())),
                              ),
                            ],
                          ),
                          Row(children: <Widget>[
                            const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text('Randomize:', style: settingTextStyle),
                            ),
                            new Radio(
                              value: 'yes',
                              groupValue: randomvalue,
                              onChanged: (value) {
                                setState(() {
                                  randomvalue = value;
                                });
                              },
                            ),
                            new Text(
                              'YES',
                              style: settingTextStyle
                            ),
                            new Radio(
                              value: 'no',
                              groupValue: randomvalue,
                              onChanged: (value) {
                                setState(() {
                                  randomvalue = value;
                                });
                              },
                            ),
                            new Text(
                              'NO',
                              style: settingTextStyle,
                            ),
                          ]),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 4,
                    child: Container(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              GestureDetector(
                                  child: Container(
                                    alignment: Alignment.center,
                                    height: 36,
                                    width: 90,
                                    decoration: BoxDecoration(
                                        color: Theme.of(context).cardColor,
                                        borderRadius: const BorderRadius.all(
                                          Radius.circular(35),
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                              color: Colors.blue,
                                              blurRadius: 2.0,
                                              spreadRadius: 2.5),
                                        ]),
                                    child: const Text(
                                      'Play Quiz',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  onTap: () => {
                                    if (int.parse(this.questionvalue) <= this.maxquestion)
                                      {
                                        Timer(Duration(milliseconds: 300), () {
                                          Navigator.of(context).pushReplacement(
                                            MaterialPageRoute(
                                              builder: (context)=> QuizPage(
                                                questiondata: questiondata,
                                                timevalue: timevalue,
                                                randomvalue: randomvalue,
                                                areavalue: areavalue,
                                                questionvalue: questionvalue,
                                                maxquestion: maxquestion,
                                                questionnumbers: questionnumbers
                                              )
                                            )
                                          );
                                        })
                                      }
                                  }
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          )
        ),
      ),
    );
  }
}

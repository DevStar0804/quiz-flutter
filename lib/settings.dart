import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:quiz/result.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // this function is called before the build so that
    // and now we return the FutureBuilder to load and decode JSON
    return FutureBuilder(
      future: DefaultAssetBundle.of(context)
          .loadString("assets/examplecsvjson.json", cache: false),
      builder: (context, snapshot) {
        Map<String, dynamic> mydata = json.decode(snapshot.data.toString());  //JSON data

        if (mydata == null) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else {
          // mydata.forEach((key, value) => {
          //       value['answer a'] = value['answer a'].toString(),
          //       value['answer b'] = value['answer b'].toString(),
          //       value['answer c'] = value['answer c'].toString(),
          //       value['answer d'] = value['answer d'].toString(),
          //       value['area'] = value['area'].toString(),
          //     });
          return SettingPage(mydata: mydata);
        }
      },
    );
  }
}

class SettingPage extends StatefulWidget {
  final Map<String, dynamic> mydata;
  SettingPage({Key key, @required this.mydata}) : super(key: key);
  @override
  _SettingPageState createState() => _SettingPageState(mydata);
}

class _SettingPageState extends State<SettingPage> {
  final Map<String, dynamic> mydata;
  _SettingPageState(this.mydata);

  Map<String, dynamic> questiondata; //real quiz data
  String timevalue = "30"; // set the initial value of countdown selection
  String randomvalue = "no"; // set the initial value of randomizing into "no"
  String areavalue = "all"; // set the initial value of category into "all category"
  String questionvalue = "2"; // set the initial number of questions into 2 questions

  Color colortoshow = Colors.indigoAccent; // initial choice button color
  Color right = Colors.green; // choice button color when answer is right
  Color wrong = Colors.red; // choice button color when answer is wrong
  bool isQuiz = false; // the value informing to start quiz
  bool disableAnswer = false; // the value which be able to click choice button or not
  int correct = 0; // number of correct answers
  int incorrect = 0; // number of wrong answers
  int maxquestion = 1; // initial value of max questions

  // extra varibale to iterate
  int i = 1; // initial No. of quiz data
  int j = 1; // random array index
  int timer = 30; // intial value of countdown
  List random_array; //randomizing questions list
  Timer test; // quiz Timer
  List incorrect_array = []; // incorrect answers and not answered list
  
  // choice button initial color
  Map<String, Color> btncolor = {
    "answer a": Colors.indigoAccent,
    "answer b": Colors.indigoAccent,
    "answer c": Colors.indigoAccent,
    "answer d": Colors.indigoAccent,
  };

  bool canceltimer = false; // initial value which be called when checking the answer
  // this function is called when a quiz is started.
  // this function returns random questions.
  genrandomarray() {
    var distinctIds = []; // randomizing questions index list
    var number = []; // randomizing questions index list
    var rand = new Random(); // 0~1 random value
    var l = 1; //question index value
    for (int i = 0;;) {
      if (this.randomvalue == "yes") {
        distinctIds.add(rand.nextInt(maxquestion) * 1 + 1);
        number.add(l);
        l++;
      } else {
        distinctIds.add(l);
        l++;
      }
      random_array = distinctIds.toSet().toList();
      incorrect_array = distinctIds.toSet().toList();
      if (random_array.length < int.parse(this.questionvalue)) {
        continue;
      } else {
        break;
      }
    }
    setState(() {
      i = random_array[0];
    });
  }

  // this function is called when start the quiz
  void starttest() {
    this.isQuiz = true;
    starttimer();
    genrandomarray();
  }

  // this fucntion is called when the page is loaded
  @override
  void initState() {
    this.maxquestion = mydata.length;
    this.questiondata = mydata;
    super.initState();
  }

  // overriding the setstate function to be called only if mounted
  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  // this function is called when start the quiz
  // runs countdown
  void starttimer() async {
    const onesec = Duration(seconds: 1);
    timer = int.parse(this.timevalue);
    test = Timer.periodic(onesec, (Timer t) {
      setState(() {
        if (timer < 1) {
          t.cancel();
          nextquestion();
        } else if (canceltimer == true) {
          t.cancel();
        } else {
          timer = timer - 1;
        }
      });
    });
  }

  // this function is called after check the answer
  void nextquestion() {
    canceltimer = false;
    timer = int.parse(this.timevalue);
    setState(() {
      if (j < int.parse(this.questionvalue)) {
        i = random_array[j];
        j++;
      } else {
        result();
      }
      btncolor["answer a"] = Colors.indigoAccent;
      btncolor["answer b"] = Colors.indigoAccent;
      btncolor["answer c"] = Colors.indigoAccent;
      btncolor["answer d"] = Colors.indigoAccent;
      disableAnswer = false;
    });
    starttimer();
  }

  // this function is called when finish the quiz
  // this function transforms the variables to result page
  result() async {
    final prefs = await SharedPreferences.getInstance();
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (context) => ResultPage(
          area: areavalue,
          parea: prefs.containsKey('$areavalue')
              ? prefs.getString('$areavalue')
              : '0',
          correct: correct,
          pcorrect: prefs.containsKey('${this.areavalue}correct')
              ? prefs.getString('${this.areavalue}correct')
              : '0',
          total: questionvalue,
          ptotal: prefs.containsKey('${this.areavalue}total')
              ? prefs.getString('${this.areavalue}total')
              : '0',
          incorrect: incorrect,
          pincorrect: prefs.containsKey('${this.areavalue}incorrect')
              ? prefs.getString('${this.areavalue}incorrect')
              : '0',
          pnotanswered: prefs.containsKey('${this.areavalue}notanswered')
              ? prefs.getString('${this.areavalue}notanswered')
              : '0',
          pscore: prefs.containsKey('${this.areavalue}score')
              ? prefs.getString('${this.areavalue}score')
              : '0',
          incorrect_array: incorrect_array,
          questiondata: questiondata),
    ));
  }

  // this function is called when click the choice button, confirm the answer whether is right or not
  void checkanswer(String k) {
    // in the previous version this was
    // questiondata[i.toString()]['correct'] == k
    // which i forgot to change
    // so nake sure that this is now corrected
    if (test != null) {
      if ('answer ' + questiondata[i.toString()]['correct'] == k) {
        // just a print sattement to check the correct working
        // debugPrint('answer'+questiondata[i.toString()]['correct'] is equal to k);
        // changing the color variable to be green
        colortoshow = right;
        correct++;
        incorrect_array.removeWhere((item) => item == i);
      } else {
        // just a print sattement to check the correct working
        // debugPrint('answer'+questiondata[i.toString()]['correct'] is equal to k);
        colortoshow = wrong;
        incorrect++;
      }
      setState(() {
        // applying the changed color to the particular button that was selected
        btncolor[k] = colortoshow;
        canceltimer = true;
        disableAnswer = true;
      });
      // nextquestion();
      // changed timer duration to 1 second
      Timer(Duration(seconds: 1), nextquestion);
    }
  }

  // choice button widget
  Widget choicebutton(String k) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: 5.0,
        horizontal: 5.0,
      ),
      child: SizedBox(
          width: screenWidth * 0.45,
          height: screenHeight * 0.25,
          child: FlatButton(
            onPressed: () => checkanswer(k),
            child: Text(
              questiondata[i.toString()][k],
              style: TextStyle(
                color: Colors.white,
                fontFamily: "Alike",
                fontSize: 12.0,
              ),
              maxLines: 10,
            ),
            color: btncolor[k],
            splashColor: Colors.indigo[700],
            highlightColor: Colors.indigo[700],
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)),
          )),
    );
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
    return DefaultTabController(
      length: 2,
      child: Builder(builder: (BuildContext context) {
        final TabController tabController = DefaultTabController.of(context);
        tabController.addListener(() {
          if (!tabController.indexIsChanging) {
            if (tabController.index == 0) {
              if (test != null) {
                test.cancel();
                j = 1;
                correct = 0;
                incorrect = 0;
                setState(() {
                  isQuiz = false;
                });
              }
            }
          }
        });
        return Scaffold(
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
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                              ),
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
                                  'Max Questions :',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16,
                                  ),
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
                                  'Category:',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16,
                                  ),
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
                                        int n = 1;
                                        mydata.forEach((key, data) {
                                          if (data['area'] == value) {
                                            questiondata[n.toString()] = data;
                                            n++;
                                          }
                                        });
                                        maxquestion = questiondata.length;
                                        questionvalue = "1";
                                      }
                                    });
                                  },
                                  value: areavalue,
                                  underline: Container(
                                    decoration: const BoxDecoration(
                                        border: Border(
                                            bottom: BorderSide(
                                                color: Colors.grey))),
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
                                  'N. of Questions:',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16,
                                  ),
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
                                            questionvalue =
                                                newValue.toString())),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          
                          Row(
                            children: <Widget>[
                              const Padding(
                                padding:
                                    EdgeInsets.all(8.0),
                                child: Icon(Icons.timer),
                              ),
                              const Padding(
                                padding:
                                    EdgeInsets.all(8.0),
                                child: Text(
                                  'Time per Question:',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16,
                                  ),
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
                              child: Text('Randomize:',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16,
                                  )),
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
                              style: new TextStyle(fontSize: 16.0),
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
                              style: new TextStyle(
                                fontSize: 16.0,
                              ),
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
                                        if (int.parse(this.questionvalue) <=
                                            this.maxquestion)
                                          {
                                            starttest(),
                                            Timer(Duration(milliseconds: 300),
                                                () {
                                              tabController.index = 1;
                                            })
                                          }
                                      }),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              isQuiz
                  ? Column(
                      children: <Widget>[
                        Row(children: [
                          Padding(
                            padding: EdgeInsets.only(left: 20, top: 20),
                            child: Center(
                              child: Text(
                                j.toString() + '/${this.questionvalue}',
                                style: TextStyle(fontSize: 16.0),
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 115, top: 20),
                            child: Center(
                              child: Text(
                                timer.toString(),
                                style: TextStyle(
                                  fontSize: 32.0,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: 'Times New Roman',
                                ),
                              ),
                            ),
                          ),
                        ]),
                        Expanded(
                          flex: 2,
                          child: Container(
                            padding: EdgeInsets.all(15.0),
                            alignment: Alignment.centerLeft,
                            child: Text(
                              questiondata[i.toString()]['question'],
                              style: TextStyle(
                                fontSize: 16.0,
                                fontFamily: "Quando",
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Center(
                            child: Image(
                              image: AssetImage('assets/filled.png'),
                              // width: 20,
                              // height: 20,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 6,
                          child: AbsorbPointer(
                            absorbing: disableAnswer,
                            child: Container(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      choicebutton('answer a'),
                                      choicebutton('answer b'),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      choicebutton('answer c'),
                                      choicebutton('answer d'),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                      mainAxisAlignment: MainAxisAlignment.start,
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          'Click the Play Quiz!',
                          style: TextStyle(fontSize: 32),
                        )
                      ],
                    ),
            ],
          ),
        );
      }),
    );
  }
}

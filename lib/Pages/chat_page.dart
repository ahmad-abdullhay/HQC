import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hqc_flutter/Models/user.dart';

import '../main.dart';

class ChatPage extends StatefulWidget {
  final User user;
  final String chatId;

  const ChatPage({Key key, this.user, @required this.chatId}) : super(key: key);
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController textEditingController = TextEditingController();
  List<QueryDocumentSnapshot> listMessage = new List.from([]);
  String getAppBarText() {
    if (widget.user.type == 'مريض')
      return 'الدردشة مع المريض ${widget.user.name}';
    if (widget.user.type == 'دكتور')
      return 'الدردشة مع الدكتور ${widget.user.name}';
    if (widget.user.type == 'ممرض')
      return 'الدردشة مع الممرض ${widget.user.name}';
    return 'الدردشة';
  }

  Widget buildmessageItem(int index, DocumentSnapshot document) {
    return Container(
        padding: EdgeInsets.symmetric(
          vertical: 3,
          horizontal: 6,
        ),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(3.0),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                      child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Row(
                      children: [
                        CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.grey[200],
                            child: Icon(
                              Icons.person,
                              color: Theme.of(context).primaryColor,
                            )),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(document['sender']),
                        )
                      ],
                    ),
                  )),
                  Text(
                    getMessageTime(DateTime.now()
                        .difference(document['date'].toDate())
                        .inSeconds),
                    style: TextStyle(color: Theme.of(context).primaryColor),
                  )
                ],
              ),
              SizedBox(
                height: 3,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 26.0),
                child: Text(document['content']),
              ),
            ]),
          ),
        ));
  }

  String getMessageTime(int differenceInSeconds) {
    int differenceInMinutes = (differenceInSeconds ~/ 60);
    if (differenceInMinutes < 60) {
      return differenceInMinutes.toString() + 'm';
    }
    int differenceInHours = (differenceInMinutes ~/ 60);
    if (differenceInHours < 24) {
      return differenceInHours.toString() + 'h';
    }
    int differenceInDays = (differenceInHours ~/ 24);
    return differenceInDays.toString() + 'd';
  }

  Future<void> sendMessage(TextEditingController textEditingController) async {
    if (textEditingController.text.isEmpty) return;
    await FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.chatId)
        .collection('messages')
        .add({
      "content": textEditingController.text,
      "date": DateTime.now(),
      "recipientId" : widget.user.firebaseID,
      "sender": ('ال' + Main.currentUser.type + ' ' + Main.currentUser.name),
    });
    textEditingController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(getAppBarText()),
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('chats')
                    .doc(widget.chatId)
                    .collection('messages')
                    .orderBy('date', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(
                        child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Theme.of(context).primaryColor)));
                  } else {
                    listMessage.addAll(snapshot.data.docs);
                    if (listMessage.length != 0) {
                      return ListView.builder(
                        padding: EdgeInsets.all(10.0),
                        itemBuilder: (context, index) =>
                            buildmessageItem(index, snapshot.data.docs[index]),
                        itemCount: snapshot.data.docs.length,
                        reverse: true,
                      );
                    } else {
                      return Center(
                          child: Container(
                        child: Text('لا يوجد رسائل بعد...'),
                      ));
                    }
                  }
                },
              ),
            ),
            Container(
              child: Row(
                children: [
                  Flexible(
                    child: Container(
                      width: double.infinity,
                      height: 50.0,
                      decoration: BoxDecoration(color: Colors.white),
                      child: TextField(
                        onSubmitted: (value) {
                          sendMessage(textEditingController);
                          textEditingController.clear();
                        },
                        style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontSize: 15.0),
                        controller: textEditingController,
                        decoration: InputDecoration.collapsed(
                          hintText: ' اكتب رسالتك هنا...',
                          hintStyle: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
                  ),
                  Material(
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 8.0),
                      child: IconButton(
                        icon: Icon(Icons.send),
                        onPressed: () => sendMessage(textEditingController),
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    color: Colors.white,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

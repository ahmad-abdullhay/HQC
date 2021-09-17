const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();
exports.notifyNewMessage = functions.firestore
    .document('chats/{channel}/messages/{message}')
    .onCreate((docSnapshot, context) => {
        const message = docSnapshot.data();
        const recipientId = message['recipientId'];
        const senderName = message['sender'];

        return admin.firestore().doc('users/' + recipientId).get().then(userDoc => {
            const registrationTokens = userDoc.get('registrationTokens')
           
            const notificationBody = "من " + senderName
            const payload = {
                notification: {
                    title: "لديك رسالة جديدة",
                    body: notificationBody,
                    //       clickAction: "ChatActivity"
                },
                // data: {
                //     USER_NAME: senderName,
                //     USER_ID: message['senderId']
                // }
            }

            return admin.messaging().sendToDevice(registrationTokens, payload).then(response => {
                const stillRegisteredTokens = registrationTokens

                response.results.forEach((result, index) => {
                    const error = result.error
                    if (error) {
                        const failedRegistrationToken = registrationTokens[index]
                        console.error('blah', failedRegistrationToken, error)
                        if (error.code === 'messaging/invalid-registration-token'
                            || error.code === 'messaging/registration-token-not-registered') {
                            const failedIndex = stillRegisteredTokens.indexOf(failedRegistrationToken)
                            if (failedIndex > -1) {
                                stillRegisteredTokens.splice(failedIndex, 1)
                            }
                        }
                    }
                })

                return admin.firestore().doc("users/" + recipientId).update({
                    registrationTokens: stillRegisteredTokens
                })
            })
        });
    });

const functions = require("firebase-functions");
const admin = require('firebase-admin');

admin.initializeApp();

const GRD_PAT_PATH = 'guardian_patient_list';
const USERS_LIST = 'users_list';
const USER_ID_KEY = 'users_id';

// Saves a message to the Firebase Realtime Database but sanitizes the text by removing swearwords.
exports.reqGuardian = functions.https.onCall(async (data, context) => {
    // if (!context.auth) return {status: 'error', code: 401, message: 'Not signed in'}
    var currentUserId = context.auth.uid;
    var patientEmail = data.patientEmail;
    var firestore = admin.firestore();
    var patientDoc = await firestore.collection(USERS_LIST).doc(patientEmail).get();
    if (patientDoc.exists() && patientDoc.data()[USER_ID_KEY] != null) {
        var patientUserId = patientDoc.data()[USER_ID_KEY];
        await firestore.collection(GRD_PAT_PATH).doc(currentUserId).set({
            patientEmail: 'pending',
        }, { merge: true });
        await firestore.collection(GRD_PAT_PATH).doc(patientUserId).collection('pending').doc(grdEmail).set({
            currentUserId: context.auth.email,
        }, { merge: true });
        return { 'status': 'success', 'code': 100, 'message': 'User\'s request has been sent' };
    } else {
        return { 'status': 'error', 'code': 404, 'message': 'Unable to find user with email ' + patientEmail };
    }
});

exports.acceptGuardian = functions.https.onCall(async (data, context) => {
    // if (!context.auth) return {status: 'error', code: 401, message: 'Not signed in'}
    var currentUserId = context.auth.uid;
    var grdEmail = data.grdEmail;
    var firestore = admin.firestore();
    var patientEmail = context.auth.uid;
    var response = data.response;
    await firestore.collection(GRD_PAT_PATH).doc(currentUserId).collection('pending').doc(grdEmail).delete();
    firestore.collection(GRD_PAT_PATH).doc(currentUserId).collection
    if (response) {
        await firestore.collection(GRD_PAT_PATH).doc(grdEmail).set({
            patientEmail: currentUserId,
        }, { merge: true });
        return { 'status': 'success', 'code': 100, 'message': 'Patient and Guardian has synced' };
    } else {
        await firestore.collection(GRD_PAT_PATH).doc(currentUserId).set({
            patientEmail: 'rejected',
        }, { merge: true });
        return { 'status': 'success', 'code': 100, 'message': 'Patient has rejected Guardian' };
    }
});

exports.storeEmail = functions.auth.user().onCreate(async(user) => {
    await admin.firestore().collection(USERS_LIST).doc(user.email).set({
        'email': (user.email ?? '').toLowerCase(),
        USER_ID_KEY: user.uid,
    },);
})
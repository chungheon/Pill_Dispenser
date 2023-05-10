const functions = require("firebase-functions");
const admin = require('firebase-admin');
const FieldValue = require('firebase-admin').firestore.FieldValue;

admin.initializeApp();

const GRD_PAT_PATH = 'guardian_patient_list';
const USER_SCH = 'user_schedule';
const USERS_LIST = 'users_list';
const USER_ID_KEY = 'users_id';
const PILL_INFO = 'information';
const USER_APPTS = 'user_appointments';

exports.reqGuardian = functions.region('asia-east2').https.onCall(async (data, context) => {
    if (!context.auth) return { status: 'error', code: 401, message: 'Not signed in' }
    var currentUserId = context.auth.uid;
    var grdEmail = (context.auth?.token?.email ?? 'ERROR').toLowerCase();
    var patientEmail = data.patientEmail.toLowerCase();
    var firestore = admin.firestore();
    var patientDoc = await firestore.collection(USERS_LIST).doc(patientEmail).get();
    if (patientDoc.exists && patientDoc.data()[USER_ID_KEY] != null) {
        var patientUserId = patientDoc.data()[USER_ID_KEY];
        await firestore.collection(GRD_PAT_PATH).doc(currentUserId).collection('Patient').doc(patientEmail).set({
            'status': 'pending',
        }, { merge: true });
        await firestore.collection(GRD_PAT_PATH).doc(patientUserId).collection('pending').doc(grdEmail).set({
            [currentUserId]: grdEmail,
        }, { merge: true });
        return { 'status': 'success', 'code': 200, 'message': 'User\'s request has been sent' };
    } else {
        return { 'status': 'error', 'code': 404, 'message': 'Unable to find user with email ' + patientEmail };
    }
});

exports.acceptGuardian = functions.region('asia-east2').https.onCall(async (data, context) => {
    if (!context.auth) return { status: 'error', code: 401, message: 'Not signed in' }
    var currentUserId = context.auth.uid;
    var grdEmail = data.grdEmail.toLowerCase();
    var firestore = admin.firestore();
    var patientEmail = (context.auth?.token?.email ?? 'ERROR').toLowerCase();
    var grdUid = data.grdUID;
    var response = data.response;
    var ref = firestore.collection(GRD_PAT_PATH).doc(currentUserId).collection('pending').doc(grdEmail);
    if ((await ref.get()).exists) {
        await ref.delete();
        if (response) {
            await firestore.collection(GRD_PAT_PATH).doc(currentUserId).collection('Guardian').doc(grdEmail).set({
                [grdEmail]: grdUid,
                'status': 'accepted'
            }, { merge: true });
            await firestore.collection(GRD_PAT_PATH).doc(grdUid).collection('Patient').doc(patientEmail).set({
                'status': 'accepted',
                [patientEmail]: currentUserId,
            }, { merge: true });
            return { 'status': 'success', 'code': 200, 'message': 'Patient and Guardian has synced' };
        } else {
            await firestore.collection(GRD_PAT_PATH).doc(grdUid).collection('Patient').doc(patientEmail).delete();
            return { 'status': 'success', 'code': 200, 'message': 'Patient has rejected Guardian' };
        }
    } else {
        return { 'status': 'error', 'code': 404, 'message': 'Request not found.' }
    }
});

exports.removeGuardianPatient = functions.region('asia-east2').https.onCall(async (data, context) => {
    if (!context.auth) return { status: 'error', code: 401, message: 'Not signed in' }
    var grdEmail = data.grdEmail.toLowerCase();
    var grdUID = data.grdUID;
    var patientEmail = data.patientEmail.toLowerCase();
    var patientUID = data.patientUID;
    var firestore = admin.firestore();
    var requestEmail = (context.auth?.token?.email ?? 'ERROR').toLowerCase();
    if (requestEmail == grdEmail || requestEmail == patientEmail) {
        await firestore.collection(GRD_PAT_PATH).doc(patientUID).collection('Guardian').doc(grdEmail).delete();
        await firestore.collection(GRD_PAT_PATH).doc(grdUID).collection('Patient').doc(patientEmail).delete();

        return { 'status': 'success', 'code': 200, 'message': 'Guardian has been removed from patient' };
    }

    return { 'status': 'error', 'code': 401, 'message': 'Unauthorized to change status' };
});

exports.fetchReq = functions.region('asia-east2').https.onCall(async (data, context) => {
    if (!context.auth) return { status: 'error', code: 401, message: 'Not signed in' }
    var currentUserId = context.auth.uid;
    var firestore = admin.firestore();
    let pendingDocs = (await firestore.collection(GRD_PAT_PATH).doc(currentUserId).collection('pending').get()).docs;
    var resp = {};
    if (pendingDocs.length > 0) {
        for (var i = 0; i < pendingDocs.length; i++) {
            var doc = await firestore.collection(USERS_LIST).doc(pendingDocs[i].id).get();
            resp[pendingDocs[i].id] = doc.data();
        }
        return { 'status': 'success', 'code': 200, 'message': 'success', 'data': resp };
    }

    return { 'status': 'success', 'code': 200, 'message': 'success' };

});


exports.fetchRelationships = functions.region('asia-east2').https.onCall(async (data, context) => {
    if (!context.auth) return { status: 'error', code: 401, message: 'Not signed in' }
    var currentUserId = context.auth.uid;
    var firestore = admin.firestore();
    let guardianDocs = (await firestore.collection(GRD_PAT_PATH).doc(currentUserId).collection('Guardian').get()).docs;
    let patientDocs = (await firestore.collection(GRD_PAT_PATH).doc(currentUserId).collection('Patient').get()).docs;
    var guardianMap = {};
    if (guardianDocs.length > 0) {
        for (var i = 0; i < guardianDocs.length; i++) {
            var doc = await firestore.collection(USERS_LIST).doc(guardianDocs[i].id).get();
            if (doc.exists) {
                guardianMap[guardianDocs[i].id] = doc.data();
            }

        }
    }

    var patientMap = {};
    if (patientDocs.length > 0) {
        for (var i = 0; i < patientDocs.length; i++) {
            var doc = await firestore.collection(USERS_LIST).doc(patientDocs[i].id).get();
            var data = patientDocs[i].data();
            if (doc.exists && data['status'] == 'accepted') {
                patientMap[patientDocs[i].id] = doc.data();
            } else if (doc.exists && data['status'] == 'pending') {
                patientMap[patientDocs[i].id] = 'pending';
            }
        }

    }

    return { 'status': 'success', 'code': 200, 'message': 'success', 'guardians': guardianMap, 'patients': patientMap };

});

exports.fetchReportData = functions.region('asia-east2').https.onCall(async (data, context) => {
    if (!context.auth) return { status: 'error', code: 401, message: 'Not signed in' }
    var currentUserId = context.auth.uid;
    var grdEmail = context.auth?.token?.email;
    if (grdEmail == null) {
        return { 'status': 'error', 'code': 401, 'message': 'User is not authorized' };
    }
    var patientEmail = data.patientEmail;
    var patientUID = data.patientUid;
    var firestore = admin.firestore();
    let guardianDocs = (await firestore.collection(GRD_PAT_PATH).doc(patientUID).collection('Guardian').get()).docs;
    if (containsObject(grdEmail.toLowerCase(), guardianDocs)) {
        var reportRef = firestore.collection('user_report').doc(patientUID);
        var doc = await reportRef.get();
        return { 'status': 'success', 'code': 200, 'data': doc.data() };
    } else {
        return { 'status': 'error', 'code': 401, 'message': 'User is not authorized' };
    }
});

exports.fetchPatientSchedule = functions.region('asia-east2').https.onCall(async (data, context) => {
    if (!context.auth) return { status: 'error', code: 401, message: 'Not signed in' }
    var currentUserId = context.auth.uid;
    var grdEmail = context.auth?.token?.email;
    if (grdEmail == null) {
        return { 'status': 'error', 'code': 401, 'message': 'User is not authorized' };
    }
    var patientUID = data.patientUid;
    var firestore = admin.firestore();
    let guardianDocs = (await firestore.collection(GRD_PAT_PATH).doc(patientUID).collection('Guardian').get()).docs;
    if (containsObject(grdEmail.toLowerCase(), guardianDocs)) {
        var scheduleRef = firestore.collection(USER_SCH).doc(patientUID);
        var doc = await scheduleRef.get();
        return { 'status': 'success', 'code': 200, 'data': doc.data() };
    } else {
        return { 'status': 'error', 'code': 401, 'message': 'User is not authorized' };
    }
});

exports.fetchAppointmentsData = functions.region('asia-east2').https.onCall(async (data, context) => {
    if (!context.auth) return { status: 'error', code: 401, message: 'Not signed in' }
    var currentUserId = context.auth.uid;
    var grdEmail = context.auth?.token?.email;
    if (grdEmail == null) {
        return { 'status': 'error', 'code': 401, 'message': 'User is not authorized' };
    }
    var patientEmail = data.patientEmail;
    var patientUID = data.patientUid;
    var firestore = admin.firestore();
    let guardianDocs = (await firestore.collection(GRD_PAT_PATH).doc(patientUID).collection('Guardian').get()).docs;
    if (containsObject(grdEmail.toLowerCase(), guardianDocs)) {
        var apptRef = firestore.collection('user_appointments').doc(patientUID).collection('appointments');
        var docs = await apptRef.get();
        var appts = {};
        docs.forEach((doc)=> {
            appts[doc.id] = doc.data();
        });
        return { 'status': 'success', 'code': 200, 'data': appts };
    } else {
        return { 'status': 'error', 'code': 401, 'message': 'User is not authorized' };
    }
});

exports.schedulePatientPill = functions.region('asia-east2').https.onCall(async (data, context) => {
    if (!context.auth) return { status: 'error', code: 401, message: 'Not signed in' }
    var currentUserId = context.auth.uid;
    var grdEmail = context.auth?.token?.email;
    if (grdEmail == null) {
        return { 'status': 'error', 'code': 401, 'message': 'User is not authorized' };
    }
    var pillName = data.pillName;
    var pillAmount = data.pillAmount;
    var pillFrequency = data.pillFrequency;
    var type = data.type;
    var scheduledTimes = data.scheduledTimes;
    var patientUID = data.patientUid;
    console.log(data);
    var firestore = admin.firestore();
    let guardianDocs = (await firestore.collection(GRD_PAT_PATH).doc(patientUID).collection('Guardian').get()).docs;
    if (containsObject(grdEmail.toLowerCase(), guardianDocs)) {
        var scheduleRef = firestore.collection(USER_SCH).doc(patientUID);
        await scheduleRef.set({
            [pillName]: {
                'amount': pillAmount,
                'frequency': pillFrequency,
                'ingestType': type,
                'pill': pillName,
                'scheduledTimes': scheduledTimes
            }
        }, { merge: true });
        return { 'status': 'success', 'code': 200 };
    } else {
        return { 'status': 'error', 'code': 401, 'message': 'User is not authorized' };
    }
});

exports.removePillSchedule = functions.region('asia-east2').https.onCall(async (data, context) => {
    if (!context.auth) return { status: 'error', code: 401, message: 'Not signed in' }
    var currentUserId = context.auth.uid;
    var grdEmail = context.auth?.token?.email;
    if (grdEmail == null) {
        return { 'status': 'error', 'code': 401, 'message': 'User is not authorized' };
    }
    var pillNames = data.pillNames;
    var patientUID = data.patientUid;
    console.log(data);
    var firestore = admin.firestore();
    let guardianDocs = (await firestore.collection(GRD_PAT_PATH).doc(patientUID).collection('Guardian').get()).docs;
    if (containsObject(grdEmail.toLowerCase(), guardianDocs)) {
        var scheduleRef = firestore.collection(USER_SCH).doc(patientUID);
        var updateMap = {};
        for (var pillName of pillNames) {
            updateMap[pillName] = FieldValue.delete();
        }
        await scheduleRef.update(updateMap);
        return { 'status': 'success', 'code': 200 };
    } else {
        return { 'status': 'error', 'code': 401, 'message': 'User is not authorized' };
    }
});

exports.updatePillsInformation = functions.region('asia-east2').https.onCall(async (data, context) => {
    if (!context.auth) return { status: 'error', code: 401, message: 'Not signed in' }
    var currentUserId = context.auth.uid;
    var grdEmail = context.auth?.token?.email;
    if (grdEmail == null) {
        return { 'status': 'error', 'code': 401, 'message': 'User is not authorized' };
    }
    var pillName = data.pillName;
    var pillInfo = data.pillInfo;
    var patientUID = data.patientUid;
    var firestore = admin.firestore();
    let guardianDocs = (await firestore.collection(GRD_PAT_PATH).doc(patientUID).collection('Guardian').get()).docs;
    if (containsObject(grdEmail.toLowerCase(), guardianDocs)) {
        var pillRef = firestore.collection(PILL_INFO).doc(patientUID);
        await pillRef.set({
            [pillName]: pillInfo,
        }, { merge: true });
        return { 'status': 'success', 'code': 200 };
    } else {
        return { 'status': 'error', 'code': 401, 'message': 'User is not authorized' };
    }
});

exports.removePillInformation = functions.region('asia-east2').https.onCall(async (data, context) => {
    if (!context.auth) return { status: 'error', code: 401, message: 'Not signed in' }
    var currentUserId = context.auth.uid;
    var grdEmail = context.auth?.token?.email;
    if (grdEmail == null) {
        return { 'status': 'error', 'code': 401, 'message': 'User is not authorized' };
    }
    var pillNames = data.pillNames;
    var patientUID = data.patientUid;
    console.log(data);
    var firestore = admin.firestore();
    let guardianDocs = (await firestore.collection(GRD_PAT_PATH).doc(patientUID).collection('Guardian').get()).docs;
    if (containsObject(grdEmail.toLowerCase(), guardianDocs)) {
        var scheduleRef = firestore.collection(PILL_INFO).doc(patientUID);
        var updateMap = {};
        for (var pillName of pillNames) {
            updateMap[pillName] = FieldValue.delete();
        }
        await scheduleRef.update(updateMap);
        return { 'status': 'success', 'code': 200 };
    } else {
        return { 'status': 'error', 'code': 401, 'message': 'User is not authorized' };
    }
});

exports.updatePatientAppt = functions.region('asia-east2').https.onCall(async (data, context) => {
    if (!context.auth) return { status: 'error', code: 401, message: 'Not signed in' }
    var grdEmail = context.auth?.token?.email;
    if (grdEmail == null) {
        return { 'status': 'error', 'code': 401, 'message': 'User is not authorized' };
    }
    var apptDateTime = data.apptDateTime;
    var apptName = data.apptName;
    var apptMsg = data.apptMsg;
    var patientUID = data.patientUid;
    var firestore = admin.firestore();
    let guardianDocs = (await firestore.collection(GRD_PAT_PATH).doc(patientUID).collection('Guardian').get()).docs;
    if (containsObject(grdEmail.toLowerCase(), guardianDocs)) {
        var apptRef = firestore.collection(USER_APPTS).doc(patientUID).collection('appointments').doc();
        await apptRef.set({
            name: apptName,
            apptDateTime: apptDateTime,
            message: apptMsg,
        }, { merge: true });
        return { 'status': 'success', 'code': 200 };
    } else {
        return { 'status': 'error', 'code': 401, 'message': 'User is not authorized' };
    }
});

exports.removePatientAppt = functions.region('asia-east2').https.onCall(async (data, context) => {
    if (!context.auth) return { status: 'error', code: 401, message: 'Not signed in' }
    var grdEmail = context.auth?.token?.email;
    if (grdEmail == null) {
        return { 'status': 'error', 'code': 401, 'message': 'User is not authorized' };
    }
    var apptId = data.apptId;
    var patientUID = data.patientUid;
    var firestore = admin.firestore();
    let guardianDocs = (await firestore.collection(GRD_PAT_PATH).doc(patientUID).collection('Guardian').get()).docs;
    if (containsObject(grdEmail.toLowerCase(), guardianDocs)) {
        var apptRef = firestore.collection(USER_APPTS).doc(patientUID).collection('appointments').doc(apptId);
        apptRef.delete();
        return { 'status': 'success', 'code': 200 };
    } else {
        return { 'status': 'error', 'code': 401, 'message': 'User is not authorized' };
    }
});

exports.addPatientAllergy = functions.region('asia-east2').https.onCall(async (data, context) => {
    if (!context.auth) return { status: 'error', code: 401, message: 'Not signed in' }
    var grdEmail = context.auth?.token?.email;
    if (grdEmail == null) {
        return { 'status': 'error', 'code': 401, 'message': 'User is not authorized' };
    }
    var allergyName = data.allergyName;
    var patientUID = data.patientUid;
    var patientEmail = data.patientEmail;
    var firestore = admin.firestore();
    let guardianDocs = (await firestore.collection(GRD_PAT_PATH).doc(patientUID).collection('Guardian').get()).docs;
    if (containsObject(grdEmail.toLowerCase(), guardianDocs)) {
        var patientRef = firestore.collection(USERS_LIST).doc(patientEmail);
        await patientRef.set({
            allergies: {
                [allergyName]: "true"
            },
        }, { merge: true });
        return { 'status': 'success', 'code': 200 };
    } else {
        return { 'status': 'error', 'code': 401, 'message': 'User is not authorized' };
    }
});

exports.removePatientAllergy = functions.region('asia-east2').https.onCall(async (data, context) => {
    if (!context.auth) return { status: 'error', code: 401, message: 'Not signed in' }
    var grdEmail = context.auth?.token?.email;
    if (grdEmail == null) {
        return { 'status': 'error', 'code': 401, 'message': 'User is not authorized' };
    }
    var allergyName = data.allergyName;
    var patientUID = data.patientUid;
    var patientEmail = data.patientEmail;
    var firestore = admin.firestore();
    let guardianDocs = (await firestore.collection(GRD_PAT_PATH).doc(patientUID).collection('Guardian').get()).docs;
    if (containsObject(grdEmail.toLowerCase(), guardianDocs)) {
        var patientRef = firestore.collection(USERS_LIST).doc(patientEmail);
        await patientRef.set({
            allergies: {
                [allergyName]: "false"
            },
        }, { merge: true });
        return { 'status': 'success', 'code': 200 };
    } else {
        return { 'status': 'error', 'code': 401, 'message': 'User is not authorized' };
    }
});

exports.fetchPatientPillInformation = functions.region('asia-east2').https.onCall(async (data, context) => {
    if (!context.auth) return { status: 'error', code: 401, message: 'Not signed in' }
    var currentUserId = context.auth.uid;
    var grdEmail = context.auth?.token?.email;
    if (grdEmail == null) {
        return { 'status': 'error', 'code': 401, 'message': 'User is not authorized' };
    }
    var patientUID = data.patientUid;
    var firestore = admin.firestore();
    let guardianDocs = (await firestore.collection(GRD_PAT_PATH).doc(patientUID).collection('Guardian').get()).docs;
    if (containsObject(grdEmail.toLowerCase(), guardianDocs)) {
        var scheduleRef = firestore.collection(PILL_INFO).doc(patientUID);
        var doc = await scheduleRef.get();
        return { 'status': 'success', 'code': 200, 'data': doc.data() };
    } else {
        return { 'status': 'error', 'code': 401, 'message': 'User is not authorized' };
    }
});



function containsObject(obj, list) {
    var i;
    for (i = 0; i < list.length; i++) {
        console.log(list[i].id);
        console.log(obj.toLowerCase());
        if (list[i].id == obj.toLowerCase()) {
            return true;
        }
    }

    return false;
}


exports.storeEmail = functions.region('asia-east2').auth.user().onCreate(async (user) => {
    var data = {
        'email': (user.email ?? '').toLowerCase(),
        'contact_details': (user.email ?? '').toLowerCase(),
        [USER_ID_KEY]: user.uid,
    }
    if (user.displayName != null) {
        data['name'] = user.displayName;
    }
    await admin.firestore().collection(USERS_LIST).doc(user.email.toLowerCase()).set(
        data
        , { merge: true });
})

exports.deleteData = functions.region('asia-east2').auth.user().onDelete(async (user) => {
    var firestore = admin.firestore();
    await firestore.collection(USERS_LIST).doc(user.email.toLowerCase()).delete();
    await firestore.collection(GRD_PAT_PATH).doc(user.uid).delete();
    await firestore.collection('user_appointments').doc(user.uid).delete();
    await firestore.collection('user_report').doc(user.uid).delete();
    await firestore.collection('user_schedule').doc(user.uid).delete();
})

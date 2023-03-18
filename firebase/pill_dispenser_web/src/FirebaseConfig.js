import { initializeApp } from "firebase/app";
import { getAuth, GoogleAuthProvider } from "firebase/auth";
import { getFirestore } from "firebase/firestore";
import { getDatabase } from "firebase/database";
import { getFunctions } from 'firebase/functions';


const firebaseConfig = {
    apiKey: "AIzaSyATaPUodTDzHiLiVJGRjINaew44VJu_u2U",
    authDomain: "pill-dispenser-bc748.firebaseapp.com",
    projectId: "pill-dispenser-bc748",
    storageBucket: "pill-dispenser-bc748.appspot.com",
    messagingSenderId: "825518165459",
    appId: "1:825518165459:web:f42483dade5420ecd7f326",
    measurementId: "G-113CZTPPX7"
};

const app = initializeApp(firebaseConfig);

export var auth = getAuth(app);
export var firestore = getFirestore(app);
export var rtdb = getDatabase(app);
export const functions = getFunctions(app, 'asia-east2');
export const googleProvider = new GoogleAuthProvider();
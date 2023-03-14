<script setup>
import firebase from "firebase";
</script>

<script>
export default {
    name: "SignUp",
    methods: {
        googleSignIn: function () {
            firebase.auth.setPersistence(firebase.browserLocalPersistence).then((res => {
                let provider = new firebase.auth.GoogleAuthProvider();
                firebase
                    .auth()
                    .signInWithPopup(provider)
                    .then((result) => {
                        let token = result.credential.accessToken;
                        let user = result.user;
                        // console.log(token) // Token
                        // console.log(user) // User that was authenticated
                    })
                    .catch((err) => {
                        console.log(err); // This will give you all the information needed to further debug any errors
                    });
            }));
        }
    },
};
</script>

<template>
    <div>
        <button @click="googleSignIn">
            Sign In with Google
        </button>
    </div>
</template>
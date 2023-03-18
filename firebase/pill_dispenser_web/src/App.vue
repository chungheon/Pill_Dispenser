<script setup>
import { RouterLink, RouterView } from 'vue-router'
import AccountHeader from './components/AccountHeader.vue'
import TextFormField from './components/TextFormField.vue';
import { auth, firestore, functions, googleProvider } from './FirebaseConfig';
import { signInWithEmailAndPassword, setPersistence, signInWithPopup, browserLocalPersistence } from 'firebase/auth';
import { state, fetchingState } from './GlobalState.js';
import { httpsCallable } from '@firebase/functions';
import { doc, getDoc } from 'firebase/firestore';
</script>

<script>
export default {
  data() {
    return {
      showLoginForm: false,
      emailText: '',
      passwordText: '',
    }
  },
  beforeMount() {
    auth.onAuthStateChanged((userState) => {
      state.user = userState;
      if (state.user != null) {
        this.fetchRelationships();
        this.getUserDetails(userState.email);
      } else {
        state.user = null;
        state.patients = {};
        state.guardians = {};
        state.birthday = null;
        state.contact = '';
        state.name = '';
      }
    });
  },
  methods: {
    login() {
      setPersistence(auth, browserLocalPersistence)
        .then(() => {

          signInWithEmailAndPassword(auth, this.emailText, this.passwordText).then((userCred) => {
            console.log('Login Successful');
            this.showLoginForm = false;
            this.emailText = '';
            this.passwordText = '';
          });
        });
    },
    loginGoogle() {
      setPersistence(auth, browserLocalPersistence).then(() => {
        signInWithPopup(auth, googleProvider)
          .then((result) => {
            console.log('Login Successful');
            this.showLoginForm = false;
            this.emailText = '';
            this.passwordText = '';
          })
          .catch((err) => {
            console.log(err); // This will give you all the information needed to further debug any errors
          });
      });
    },
    closeDrawer() {
      this.showLoginForm = false;
    },
    async getUserDetails(email) {
      const docRef = doc(firestore, '/users_list', email);
      const result = await getDoc(docRef);
      const data = result.data();
      state.name = data['name'];
      state.email = data['email'];
      state.contact = data['contact_details'];
    },
    fetchRelationships() {
      if (state.user != null) {
        fetchingState.fetchingRelationships = true;
        const relationships = httpsCallable(functions, 'fetchRelationships');
        relationships()
          .then((result) => {
            const data = result.data;
            console.log(data);
            state.patients = data['patients'] ?? {};
            state.guardians = data['guardians'] ?? {};
            fetchingState.fetchingRelationships = false;
          });
      }
    }
  }
}
</script>

<style scoped>
.nav_bar {
  background-color: white;
  box-shadow: 0 0 5px 4px rgba(0, 0, 0, 0.1);
  z-index: 2;
}

.navigation {
  display: flex;
  width: 100%;
  padding: 20px;

}

a {
  text-decoration: none;
  color: black;
  font-size: 1.2rem;
  font-weight: 500;
  padding: 0px 10px 0px 10px;
}

.nav_section {
  display: flex;
  bottom: 0px;
}

.account_header {
  margin-left: auto;
  margin-right: 5px;
  order: 2;
}

.close {
  margin-left: auto;
  width: 32px;
  height: 32px;
  opacity: 0.3;
}

.close:hover {
  opacity: 1;
}

.close:before,
.close:after {
  position: absolute;
  left: 15px;
  content: ' ';
  height: 33px;
  width: 2px;
  background-color: #333;
}

.close:before {
  transform: rotate(45deg);
}

.close:after {
  transform: rotate(-45deg);
}

.login_form_drawer {
  position: absolute;
  background-color: white;
  right: 0px;
  top: 0px;
  bottom: 0px;
  padding-bottom: auto;
  z-index: 3;
}

.login_form {
  padding: 0px 20px 0px 20px;
}

.login_btn {
  margin-top: 20px;
  font-size: 1rem;
  font-weight: 600;
  width: 100%;
  border-radius: 15px;
  background-color: greenyellow;
  padding: 5px 0px 5px 0px;
}

.google-btn {
  margin-top: 20px;
  font-size: 1rem;
  font-weight: 600;
  width: 100%;
  border-radius: 15px;
  background-color: white;
  padding: 5px 0px 5px 0px;
}
</style>

<template>
  <header class="nav_bar">
    <section>
      <nav class="navigation" style="color: rgb(0,0,25);">
        <div class="nav_section">
          <RouterLink to="/">Home</RouterLink>
          <RouterLink to="/patients" v-if="state.user != null">Patients</RouterLink>
        </div>
        <AccountHeader class="account_header" v-bind:isLoggedIn="state.user != null" :showFormValue="showLoginForm"
          v-bind:showFormValue="showLoginForm" v-on:update:showFormValue="showLoginForm = $event" />
      </nav>
    </section>
  </header>
  <section class="login_form_drawer" v-if="showLoginForm">
    <div style="margin:15px 20px 0px 0px; display:flex;"><a class="close" @click="closeDrawer" /></div>
    <section class="login_form">
      <form>
        <TextFormField label="Email" v-model="emailText" hintText="Enter your Email" type="email" />
        <TextFormField label="Password" v-model="passwordText" hintText="Password" type="password" />
      </form>
      <button class="login_btn" type="submit" @click="login">Login</button>
      <button class="google-btn" type="submit" @click="loginGoogle">Google Sign In/Sign Up</button>
    </section>

  </section>

  <section class="router_view">
    <RouterView />
  </section>
</template>

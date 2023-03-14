<script setup>
import { signOut } from "firebase/auth";
import { auth } from "../FirebaseConfig";
import { state } from "../GlobalState";
</script>

<script>
export default {
    data() {
        return {
        }
    },
    methods: {
        toggleShow() {
            var currValue = !this.showFormValue;
            this.$emit("update:showFormValue", currValue);
        },
        logOut() {
            signOut(auth);
        },
    },
    props: ['isLoggedIn', 'showFormValue'],
}


</script>

<style scoped>
.login {
    text-decoration: none;
    color: black;
    font-size: 1.2rem;
    font-weight: 500;
    cursor: pointer;
}

.account{
    display: flex;
}

.account_details{
    padding: 0px 10px 0px 0px;
}

#user_email{
    font-size: 1.2rem;
}
#user_role{
    font-size: 0.8rem;
}

</style>
<template>
    <section>
        <section class="account" v-if="isLoggedIn">
            <div class="account_details">
                <p id="user_email">
                {{ state?.user?.email ?? 'no email' }}
            </p>
            </div>
            <p class="login" @click="logOut">
                Logout
            </p>
        </section>
        <section v-else>
            <p class="login" @click="toggleShow">
                Login
            </p>
        </section>
    </section>
</template>
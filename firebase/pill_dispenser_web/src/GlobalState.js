import { reactive } from "vue";

export const state = reactive({
    user: null,
    name: '',
    contact: '',
    birthday: null,
    guardians: {},
    patients: {},
})
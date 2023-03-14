<script>
export default {
    props: ['label', 'type', 'hintText', 'modelValue', 'width', 'inputLength', 'min', 'max'],
    computed: {
        inputValue: {
            get() {
                return this.modelValue;
            },
            set(value) {
                this.$emit('update:modelValue', value);
            }
        }
    }
}
</script>

<template>
    <section>
        <label>{{ label }}</label>
        <br />
        <div>
            <input :length="inputLength ?? 2" :type="type" v-model="inputValue" :placeholder="hintText"
                v-bind:style="this.width != null ? 'width:' + this.width : ''" :min="this.min" :max="this.max" />
        </div>
    </section>
</template>

<style scoped>
input {
    border-radius: 25px;
    width: 35ch;
    font-size: 1rem;
    padding: 0.7em;
    margin: 5px 0px 0px 0px;

}

label {
    font-size: 1.3rem;
    color: rgb(31, 31, 31);
}

section {
    margin-top: 10px;
    margin-bottom: 10px;
}
</style>

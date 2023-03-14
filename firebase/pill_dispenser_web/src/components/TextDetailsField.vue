<script>
export default {
    props: ['label', 'modelValue', 'width'],
}
</script>

<template>
    <section>
        <label>{{ label }}</label>
        <br />
        <div>
            <p id="details" v-bind:style="this.width != null ? 'width:' + this.width : ''">{{ modelValue }}</p>
        </div>
    </section>
</template>

<style scoped>
#details {
    background-color: rgba(128, 128, 128, 0.20);
    color: black; 
    font-size: 1rem;
    padding: 0.7em;
    margin: 0px 0px 0px 0px;
    width: 100%;
}

label {
    font-size: 1.3rem;
    color: rgb(31, 31, 31);
}

</style>
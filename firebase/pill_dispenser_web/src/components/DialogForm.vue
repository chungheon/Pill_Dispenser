<template>
    <div class="dialog" v-if="visible">
      <div class="dialog-overlay"></div>
      <div class="dialog-content">
        <h2>{{ title }}</h2>
        <p>{{ message }}</p>
        <div class="dialog-buttons">
          <button @click="confirm">OK</button>
        </div>
      </div>
    </div>
  </template>
  
  <script>
  export default {
    props: {
      title: String,
      message: String,
      visible: Boolean
    },
    methods: {
      close() {
        this.$emit('update:visible', false)
      },
      confirm() {
        this.$emit('confirmed')
        this.close()
      }
    }
  }
  </script>
  
  <style>
  .dialog {
    position: fixed;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    z-index: 9999;
  }
  
  .dialog-overlay {
    position: absolute;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    background-color: rgba(0, 0, 0, 0.5);
  }
  
  .dialog-content {
    position: absolute;
    top: 50%;
    left: 50%;
    transform: translate(-50%, -50%);
    background-color: white;
    padding: 20px;
    border-radius: 5px;
    box-shadow: 0 0 10px rgba(0, 0, 0, 0.3);
  }
  
  .dialog-buttons {
    text-align: right;
    margin-top: 20px;
  }
  
  .dialog-buttons button {
    margin-left: 10px;
  }
  </style>
  
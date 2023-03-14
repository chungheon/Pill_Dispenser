<script setup>

</script>

<style scoped>
main{
  min-height: 95vh;
  width: 100%;
}

section {
  padding: 20px;
  display: flex;
  justify-content: center;
}

.screenshots{
  width: 20%;
  max-width: 750px;
  max-height: 1500px;
  background-color: black;
  margin: 1%;
}

</style>


<template>
  <main>
    <section>
      <img class="screenshots" src="@/assets/splash_screen.png"/>
      <img class="screenshots" src="@/assets/login.png"/>
      <img class="screenshots" src="@/assets/home.png"/>
    </section>
    <section>
      <img class="screenshots" src="@/assets/drawer.png"/>
      <img class="screenshots" src="@/assets/pill_information.png"/>
      <img class="screenshots" src="@/assets/schedule_appointment.png"/>
    </section>
  </main>
</template>

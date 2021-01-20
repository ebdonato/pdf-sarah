<template>
    <div id="q-app">
        <router-view />
    </div>
</template>
<script>
export default {
    name: "App",
    mounted() {
        this.$q.dark.set(this.$q.localStorage.getItem("darkTheme")) ?? false
    },
}
</script>

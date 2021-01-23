<template>
    <div id="q-app">
        <router-view />
    </div>
</template>
<script>
export default {
    name: "App",
    mounted() {
        this.$q.dark.set(this.$q.localStorage.getItem("darkTheme") ?? false)

        this.$store.commit(
            "config/updateDefaultOutputFolderConfig",
            this.$q.localStorage.getItem("defaultOutputFolder") ?? true
        )
        this.$store.commit(
            "config/updateClearSelectionConfig",
            this.$q.localStorage.getItem("clearSelection") ?? true
        )
    },
}
</script>

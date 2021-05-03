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
        this.$store.commit("config/updateZoomLevelConfig", this.$q.localStorage.getItem("zoomLevel") ?? 30)
        this.$store.commit("config/updateShowLinksConfig", this.$q.localStorage.getItem("showLinks") ?? true)
        this.$store.commit("config/updateLeftDrawerOpenConfig", this.$q.localStorage.getItem("leftDrawerOpen") ?? true)
    },
}
</script>

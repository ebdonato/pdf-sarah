<template>
    <q-layout view="lHh Lpr lFf" :class="bgClass">
        <q-header :class="$q.dark.isActive ? 'bg-primary' : 'bg-secondary'">
            <q-toolbar>
                <q-btn
                    unelevated
                    :text-color="$q.dark.isActive ? 'secondary' : 'primary'"
                    round
                    icon="menu"
                    aria-label="Menu"
                    @click="leftDrawerOpen = !leftDrawerOpen"
                />
                <q-toolbar-title :class="$q.dark.isActive ? 'text-secondary' : 'text-primary'"
                    >PDF da Dona Sarah</q-toolbar-title
                >
            </q-toolbar>
        </q-header>

        <q-drawer v-model="leftDrawerOpen" bordered :content-class="$q.dark.isActive ? 'bg-purple-4' : 'bg-purple-1'">
            <div class="full-height column no-wrap justify-between">
                <div>
                    <div class="q-ma-none q-pa-md text-center">
                        <img alt="PDF da Dona Sarah" src="icons\favicon-128x128.png" />
                    </div>
                    <q-btn
                        flat
                        size="sm"
                        :icon="showLinks ? 'keyboard_arrow_up' : 'keyboard_arrow_down'"
                        @click="showLinks = !showLinks"
                        class="full-width"
                    />

                    <q-slide-transition :duration="500">
                        <q-list v-if="showLinks">
                            <q-item-label header> Links </q-item-label>
                            <EssentialLink v-for="link in essentialLinks" :key="link.title" v-bind="link" />
                        </q-list>
                    </q-slide-transition>

                    <div>
                        <q-select
                            outlined
                            v-model="theme"
                            :options="['Claro', 'Escuro']"
                            label="Tema"
                            class="q-ma-md"
                        />
                        <q-select
                            outlined
                            v-model="outputFolder"
                            :options="['Local Padrão', 'Escolher local']"
                            label="Salvar em"
                            class="q-ma-md"
                        />
                        <q-select
                            outlined
                            v-model="clearSelection"
                            :options="['Sim', 'Não']"
                            label="Limpar seleção ao salvar"
                            class="q-ma-md"
                        />
                        <div class="q-ma-md">
                            <div>Tamanho das Páginas</div>

                            <q-slider
                                v-model="zoomLevel"
                                :min="10"
                                :max="100"
                                :step="10"
                                snap
                                label
                                :label-value="`${zoomLevel}%`"
                            />
                        </div>
                    </div>
                </div>

                <div class="row q-ma-md items-end">
                    <q-btn round @click="autoClose">
                        <q-avatar>
                            <img src="eu.jpg" />
                        </q-avatar>
                    </q-btn>
                    <q-space />
                    <span> App v{{ version }} | Quasar v{{ $q.version }} </span>
                </div>
            </div>
        </q-drawer>

        <q-page-container>
            <router-view />
        </q-page-container>

        <q-footer :class="$q.dark.isActive ? 'footer-bg-dark' : 'footer-bg-light'">
            <transition appear enter-active-class="animated fadeIn" leave-active-class="animated fadeOut">
                <q-banner inline-actions class="text-primary" v-show="showAppInstallBanner">
                    <template v-slot:avatar>
                        <q-icon name="system_update" color="primary" />
                    </template>
                    Deseja instalar o aplicativo?
                    <template v-slot:action>
                        <q-btn flat color="primary" label="Sim" @click="installApp" />
                        <q-btn flat color="primary" label="Depois" @click="showAppInstallBanner = false" />
                        <q-btn flat color="primary" label="Nunca" @click="neverShowAppInstallBanner" />
                    </template>
                </q-banner>
            </transition>
            <div
                class="text-center text-caption text-weight-thin"
                :class="$q.dark.isActive ? 'text-secondary' : 'text-primary'"
            >
                &copy; {{ new Date().getFullYear() }}
            </div>
        </q-footer>
    </q-layout>
</template>

<script>
import EssentialLink from "components/EssentialLink.vue"
import { version } from "../../package.json"

const linksData = [
    {
        title: "Github",
        caption: "github.com/ebdonato",
        icon: "code",
        link: "https://github.com/ebdonato",
    },
    {
        title: "Twitter",
        caption: "@ebdonato",
        icon: "rss_feed",
        link: "https://twitter.com/ebdonato",
    },
    {
        title: "Gravatar",
        caption: "@ebdonato",
        icon: "record_voice_over",
        link: "https://gravatar.com/ebdonato",
    },
    {
        title: "Linkedin",
        caption: "@ebdonato",
        icon: "apartment",
        link: "https://www.linkedin.com/in/ebdonato/",
    },
    {
        title: "Instagram",
        caption: "@ebdonato",
        icon: "insert_photo",
        link: "https://instagram.com/ebdonato",
    },
]

export default {
    name: "MainLayout",
    components: { EssentialLink },
    data() {
        return {
            essentialLinks: linksData,
            version,
            showAppInstallBanner: false,
            deferredPrompt: null,
        }
    },
    computed: {
        outputFolder: {
            get() {
                return this.$store.state.config.defaultOutputFolder ? "Local Padrão" : "Escolher local"
            },
            set(value) {
                const option = value === "Local Padrão"
                this.$store.commit("config/updateDefaultOutputFolderConfig", option)
                this.$q.localStorage.set("defaultOutputFolder", option)
            },
        },
        zoomLevel: {
            get() {
                return this.$store.state.config.zoomLevel
            },
            set(value) {
                this.$store.commit("config/updateZoomLevelConfig", value)
                this.$q.localStorage.set("zoomLevel", value)
            },
        },
        showLinks: {
            get() {
                return this.$store.state.config.showLinks
            },
            set(value) {
                this.$store.commit("config/updateShowLinksConfig", !!value)
                this.$q.localStorage.set("showLinks", !!value)
            },
        },
        leftDrawerOpen: {
            get() {
                return this.$store.state.config.leftDrawerOpen
            },
            set(value) {
                this.$store.commit("config/updateLeftDrawerOpenConfig", !!value)
                this.$q.localStorage.set("leftDrawerOpen", !!value)
            },
        },
        clearSelection: {
            get() {
                return this.$store.state.config.clearSelection ? "Sim" : "Não"
            },
            set(value) {
                const option = value === "Sim"
                this.$store.commit("config/updateClearSelectionConfig", option)
                this.$q.localStorage.set("clearSelection", option)
            },
        },
        bgClass() {
            return this.$q.dark.isActive ? "drawer-bg-dark" : "drawer-bg-light"
        },
        theme: {
            get() {
                return this.$q.dark.isActive ? "Escuro" : "Claro"
            },
            set(value) {
                this.$q.dark.set(value === "Escuro")
                this.$q.localStorage.set("darkTheme", this.$q.dark.isActive)
            },
        },
    },
    methods: {
        autoClose() {
            let seconds = 5

            const dialog = this.$q
                .dialog({
                    title: "Desenvolvido por",
                    message: "Eduardo Batista Donato",
                })
                .onOk(() => {
                    // console.log('OK')
                })
                .onCancel(() => {
                    // console.log('Cancel')
                })
                .onDismiss(() => {
                    clearTimeout(timer)
                    // console.log('I am triggered on both OK and Cancel')
                })

            const timer = setInterval(() => {
                seconds--

                if (seconds <= 0) {
                    clearInterval(timer)
                    dialog.hide()
                }
            }, 1000)
        },
        installApp() {
            // Hide the app provided install promotion
            this.showAppInstallBanner = false
            // Show the install prompt
            this.deferredPrompt.prompt()
            // Wait for the user to respond to the prompt
            this.deferredPrompt.userChoice.then(choiceResult => {
                if (choiceResult.outcome === "accepted") {
                    console.log("User accepted the install prompt")
                } else {
                    console.log("User dismissed the install prompt")
                }
            })
        },
        neverShowAppInstallBanner() {
            this.showAppInstallBanner = false
            this.$q.localStorage.set("neverShowAppInstallBanner", true)
        },
    },
    mounted() {
        const neverShowAppInstallBanner = this.$q.localStorage.getItem("neverShowAppInstallBanner")

        if (!neverShowAppInstallBanner) {
            window.addEventListener("beforeinstallprompt", e => {
                // Prevent the mini-infobar from appearing on mobile
                e.preventDefault()
                // Stash the event so it can be triggered later.
                this.deferredPrompt = e
                // Update UI notify the user they can install the PWA

                setTimeout(() => {
                    this.showAppInstallBanner = true
                }, 3000)
            })
        }
    },
}
</script>

<style lang="sass">
.drawer-bg-light
    background: $secondary
    // background: -webkit-linear-gradient(to bottom, $color1, $color2)
    // background: linear-gradient(to bottom, $color1, $color2)

.drawer-bg-dark
    background: $primary
    // background: -webkit-linear-gradient(to bottom, $color3, $color4)
    // background: linear-gradient(to bottom, $color3, $color4)

.footer-bg-light
    background: $secondary
    //background: -webkit-linear-gradient(to bottom, $secondary, $dark)
    //background: linear-gradient(to bottom, $secondary, $dark)
.footer-bg-dark
    background: $primary
    //background: -webkit-linear-gradient(to bottom, $primary, $dark)
    //background: linear-gradient(to bottom, $primary, $dark)


.skyline
    background: url(../../public/skyline.png)
    background-size: contain
    background-position: center bottom

.bg-translucid
    background: #000000c5
</style>

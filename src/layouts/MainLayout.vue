<template>
    <q-layout view="lHh lpR lFf">
        <q-header elevated>
            <q-toolbar>
                <q-btn
                    flat
                    dense
                    round
                    icon="menu"
                    aria-label="Menu"
                    @click="leftDrawerOpen = !leftDrawerOpen"
                />

                <q-avatar square v-show="!leftDrawerOpen">
                    <img src="icons\favicon-32x32.png" />
                </q-avatar>

                <q-toolbar-title> PDF da Sarah </q-toolbar-title>

                <q-btn round @click="autoClose">
                    <q-avatar>
                        <img src="eu.jpg" />
                    </q-avatar>
                </q-btn>
            </q-toolbar>
        </q-header>

        <q-drawer
            v-model="leftDrawerOpen"
            show-if-above
            bordered
            :content-class="$q.dark.isActive ? 'bg-purple-4' : 'bg-purple-1'"
        >
            <div class="q-ma-none q-pa-md text-center">
                <img alt="PDF da Sarah" src="icons\favicon-128x128.png" />
            </div>

            <q-list>
                <q-item-label header> Links </q-item-label>
                <EssentialLink
                    v-for="link in essentialLinks"
                    :key="link.title"
                    v-bind="link"
                />
            </q-list>

            <q-select
                outlined
                v-model="theme"
                :options="['Claro', 'Escuro']"
                label="Tema"
                class="q-ma-md"
            />

            <div class="q-ma-md">
                App v{{ version }} | Quasar v{{ $q.version }}
            </div>
        </q-drawer>

        <q-page-container>
            <router-view />
        </q-page-container>

        <transition
            appear
            enter-active-class="animated fadeIn"
            leave-active-class="animated fadeOut"
        >
            <q-footer elevated v-show="showAppInstallBanner">
                <q-banner inline-actions class="text-primary">
                    <template v-slot:avatar>
                        <q-icon name="system_update" color="primary" />
                    </template>
                    Deseja instalar o aplicativo?
                    <template v-slot:action>
                        <q-btn
                            flat
                            color="primary"
                            label="Sim"
                            @click="installApp"
                        />
                        <q-btn
                            flat
                            color="primary"
                            label="Depois"
                            @click="showAppInstallBanner = false"
                        />
                        <q-btn
                            flat
                            color="primary"
                            label="Nunca"
                            @click="neverShowAppInstallBanner"
                        />
                    </template>
                </q-banner>
            </q-footer>
        </transition>
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
        title: "Facebook",
        caption: "@ebdonato",
        icon: "public",
        link: "https://fb.me/ebdonato",
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
            leftDrawerOpen: false,
            essentialLinks: linksData,
            version,
            showAppInstallBanner: false,
            deferredPrompt: null,
        }
    },
    computed: {
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
            this.deferredPrompt.userChoice.then((choiceResult) => {
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
        const neverShowAppInstallBanner = this.$q.localStorage.getItem(
            "neverShowAppInstallBanner"
        )

        if (!neverShowAppInstallBanner) {
            window.addEventListener("beforeinstallprompt", (e) => {
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

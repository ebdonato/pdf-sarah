<template>
    <q-layout view="lHh Lpr lFf">
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
    },
}
</script>

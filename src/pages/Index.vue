<template>
    <q-page padding>
        <q-file
            v-model="file"
            @input="pickerPDF"
            accept=".pdf"
            :disable="fileChosen"
            :label="fileChosen ? 'PDF aberto' : 'Abrir PDF'"
        >
            <template v-slot:prepend>
                <q-icon name="attach_file" />
            </template>

            <template v-slot:after>
                <div v-show="fileChosen" class="q-gutter-sm">
                    <q-btn round dense flat icon="clear" @click="resetData" />
                    <q-btn
                        round
                        dense
                        flat
                        icon="get_app"
                        @click="getNewDoc"
                        :disable="!fileLoaded || !numSelectedPages"
                    >
                        <q-badge color="red" floating v-if="numSelectedPages">{{
                            numSelectedPages
                        }}</q-badge>
                    </q-btn>
                </div>
            </template>
        </q-file>

        <div
            class="fit row wrap justify-around items-start content-start q-my-sm q-gutter-xs"
        >
            <div
                v-for="page in numPages"
                :key="page"
                class="col-11 col-md-3"
                @click="selected[page] = !selected[page]"
                :class="{ pageSelected: selected[page] }"
            >
                <div class="row">
                    <q-checkbox v-model="selected[page]" :label="`${page}`" />
                    <q-space />
                    <q-btn
                        flat
                        round
                        icon="rotate_left"
                        size="md"
                        @click.stop="rotatePage(page, false)"
                    />
                    <q-btn
                        flat
                        round
                        icon="rotate_right"
                        size="md"
                        @click.stop="rotatePage(page, true)"
                    />
                </div>
                <div class="q-pa-xs">
                    <pdf :src="src" :page="page" :rotate="rotate[page]" />
                </div>
            </div>
        </div>
        <q-page-sticky position="bottom-right" :offset="[18, 18]">
            <q-btn
                fab
                icon="get_app"
                color="accent"
                @click="getNewDoc"
                :disable="!fileLoaded || !numSelectedPages"
            >
                <q-badge color="red" floating v-if="numSelectedPages">{{
                    numSelectedPages
                }}</q-badge>
            </q-btn>
        </q-page-sticky>
    </q-page>
</template>

<script>
import pdf from "vue-pdf"
import { PDFDocument, degrees } from "pdf-lib"

const download = require("downloadjs")

export default {
    name: "PageIndex",
    components: {
        pdf,
    },
    data() {
        return {
            src: null,
            numPages: undefined,
            selected: {},
            file: null,
            fileChosen: false,
            pdfDocument: null,
            fileLoaded: false,
            rotate: {},
        }
    },
    computed: {
        numSelectedPages() {
            return Object.keys(this.selected).filter(
                (page) => this.selected[page]
            ).length
        },
    },
    methods: {
        rotatePage(page, clockwise = true) {
            const oldAngle = this.rotate[page] ?? 0
            const newAngle = oldAngle + (clockwise ? 90 : -90)

            this.rotate[page] =
                newAngle < 0 ? 270 : newAngle >= 360 ? 0 : newAngle
        },
        pickerPDF(file) {
            if (this.fileChosen && file) {
                Object.assign(this.$data, this.$options.data())
            }

            if (!file) return

            this.$q.loading.show()

            this.src = pdf.createLoadingTask(window.URL.createObjectURL(file))

            Promise.all([this.src.promise, file.arrayBuffer()])
                .then((results) => {
                    //pdf para exibição
                    this.numPages = results[0].numPages
                    this.fileChosen = true
                    this.unselectAllPages()
                    //pdf para tratamento interno
                    this.pdfDocument = PDFDocument.load(results[1])
                    this.fileLoaded = true
                })
                .catch((err) => {
                    this.$q.notify({
                        message: "Algo deu errado ao ler o PDF.",
                        color: "negative",
                    })
                    console.error(err)
                })
                .finally(() => {
                    this.$q.loading.hide()
                })

            // this.src.promise
            //     .then((pdf) => {
            //         this.numPages = pdf.numPages
            //         this.fileChosen = true

            //         this.unselectAllPages()
            //     })

            // file.arrayBuffer()
            //     .then((buffer) => PDFDocument.load(buffer))
            //     .then((pdfDoc) => {
            //         this.pdfDocument = pdfDoc
            //         this.fileLoaded = true
            //     })
        },
        unselectAllPages(cleanRotateInfo = true) {
            if (this.numPages) {
                for (let index = 1; index <= this.numPages; index++) {
                    this.$set(this.selected, index, false)
                    cleanRotateInfo && this.$set(this.rotate, index, 0)
                }
            }
        },
        isValidFilename(filename) {
            const rg1 = /^[^\\/:\*\?"<>\|]+$/ // forbidden characters \ / : * ? " < > |
            const rg2 = /^\./ // cannot start with dot (.)
            const rg3 = /^(nul|prn|con|lpt[0-9]|com[0-9])(\.|$)/i // forbidden file names

            return (
                rg1.test(filename) && !rg2.test(filename) && !rg3.test(filename)
            )
        },
        getNewDoc() {
            if (this.$store.state.config.defaultOutputFolder) {
                this.createNewDocDefaultFolder()
            } else {
                this.createNewDoc()
            }
        },
        createNewDocDefaultFolder() {
            this.$q
                .dialog({
                    title: "Criar PDF",
                    message: "Qual o nome do novo arquivo (sem extensão)?",
                    prompt: {
                        model: "",
                        type: "text", // optional
                    },
                    cancel: true,
                    persistent: true,
                })
                .onOk((fileNameChosen) => {
                    if (
                        typeof fileNameChosen === "string" &&
                        this.isValidFilename(fileNameChosen)
                    ) {
                        this.createNewPDFDocumentPromise()
                            .then((pdfBytes) => {
                                download(
                                    pdfBytes,
                                    `${fileNameChosen}.pdf`,
                                    "application/pdf"
                                )
                            })
                            .catch((err) => {
                                this.$q.notify({
                                    message:
                                        "Algo deu errado ao criar o novo arquivo.",
                                    color: "negative",
                                })
                                console.error(err)
                            })
                    } else {
                        this.$q.notify({
                            message: "Nome de Arquivo Inválido.",
                            color: "negative",
                        })
                    }
                })
        },
        createNewPDFDocumentPromise() {
            const pages = Object.keys(this.selected)
                .filter((page) => this.selected[page])
                .map((page) => parseInt(page) - 1)

            let _newPdf

            return PDFDocument.create()
                .then((pdfDoc) => (_newPdf = pdfDoc))
                .then((pdfDoc) => pdfDoc.copyPages(this.pdfDocument, pages))
                .then((copiedPages) => {
                    copiedPages.forEach((page, index) => {
                        const angle = this.rotate[pages[index] + 1]
                        page.setRotation(degrees(angle))
                        _newPdf.addPage(page)
                    })

                    if (this.$store.state.config.clearSelection) {
                        this.unselectAllPages(false)
                    }

                    return _newPdf.save()
                })
        },
        async createNewDoc() {
            const opts = {
                types: [
                    {
                        description: "Arquivos PDF",
                        accept: { "application/pdf": [".pdf"] },
                    },
                ],
            }

            let writable

            try {
                const handle = await window.showSaveFilePicker(opts)
                writable = await handle.createWritable()
            } catch (error) {
                return
            }

            this.createNewPDFDocumentPromise()
                .then((pdfBytes) => writable.write(pdfBytes))
                .then(() => {
                    this.$q.notify({
                        message: "Arquivo criado com sucesso",
                        color: "positive",
                    })
                })
                .catch(() => {
                    this.$q.notify({
                        message: "Algo deu errado ao criar o novo arquivo.",
                        color: "negative",
                    })
                })
                .finally(() => {
                    writable.close()
                })
        },
        resetData() {
            Object.assign(this.$data, this.$options.data())
        },
    },
}
</script>

<style lang="sass" scoped>
.pageSelected
    background: $accent
</style>

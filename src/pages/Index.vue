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
                <q-btn round dense flat icon="clear" @click="resetData" />
            </template>
        </q-file>

        <div
            class="fit row wrap justify-start items-start content-start q-my-sm q-gutter-sm"
        >
            <div
                v-for="page in numPages"
                :key="page"
                class="q-pa-xs"
                @click="selected[page] = !selected[page]"
                :class="{ pageSelected: selected[page] }"
            >
                <q-checkbox v-model="selected[page]" :label="`${page}`" />
                <pdf :src="src" :page="page" />
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
import { PDFDocument } from "pdf-lib"

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
        pickerPDF(file) {
            if (this.fileChosen && file) {
                Object.assign(this.$data, this.$options.data())
            }

            if (!file) return

            this.src = pdf.createLoadingTask(window.URL.createObjectURL(file))
            this.src.promise.then((pdf) => {
                this.numPages = pdf.numPages
                this.fileChosen = true

                this.unselectAllPages()
            })

            file.arrayBuffer()
                .then((buffer) => PDFDocument.load(buffer))
                .then((pdfDoc) => {
                    this.pdfDocument = pdfDoc
                    this.fileLoaded = true
                })
        },
        unselectAllPages() {
            if (this.numPages) {
                for (let index = 1; index <= this.numPages; index++) {
                    this.$set(this.selected, index, false)
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
                                this.unselectAllPages()
                                download(
                                    pdfBytes,
                                    `${fileNameChosen}.pdf`,
                                    "application/pdf"
                                )
                            })
                            .catch((err) => {
                                this.$q.notify({
                                    message:
                                        "Algo deu ao criar o novo arquivo.",
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
                    copiedPages.forEach((page) => _newPdf.addPage(page))
                    if (this.$store.state.config.clearSelection) {
                        this.unselectAllPages()
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
                        message: "Algo deu ao criar o novo arquivo.",
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
    border: 1px dotted $primary
</style>

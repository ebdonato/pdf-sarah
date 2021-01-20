<template>
    <q-page padding>
        <q-file
            v-model="file"
            @input="pickerPDF"
            accept=".pdf"
            :disable="fileChosen"
            :label="
                fileChosen
                    ? 'Nome do Arquivo Original'
                    : 'Clique aqui para escolher o arquivo PDF original'
            "
        >
            <template v-slot:prepend>
                <q-icon name="attach_file" />
            </template>

            <template v-slot:after>
                <q-btn
                    round
                    dense
                    flat
                    icon="shopping_cart"
                    @click="resetData"
                />
            </template>
        </q-file>

        <div
            class="fit row wrap justify-start items-start content-start q-my-sm"
        >
            <div v-for="page in numPages" :key="page" class="q-pa-xs">
                <q-checkbox v-model="selected[page]" :label="`${page}`" />
                <pdf :src="src" :page="page" />
            </div>
        </div>
        <q-page-sticky position="bottom-right" :offset="[18, 18]">
            <q-btn
                fab
                icon="get_app"
                color="accent"
                @click="createNewDocDialog"
                :disable="!fileLoaded"
            />
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

                for (let index = 1; index <= this.numPages; index++) {
                    this.$set(this.selected, index, false)
                }
            })

            file.arrayBuffer()
                .then((buffer) => PDFDocument.load(buffer))
                .then((pdfDoc) => {
                    this.pdfDocument = pdfDoc
                    this.fileLoaded = true
                })
        },
        createNewDocDialog() {
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
                .onOk((data) => {
                    if (
                        typeof data === "string" &&
                        this.isValidFilename(data)
                    ) {
                        this.createNewDoc(data)
                    } else {
                        this.$q.notify({
                            message: "Nome de Arquivo Inválido.",
                            color: "negative",
                        })
                    }
                })
        },
        isValidFilename(filename) {
            const rg1 = /^[^\\/:\*\?"<>\|]+$/ // forbidden characters \ / : * ? " < > |
            const rg2 = /^\./ // cannot start with dot (.)
            const rg3 = /^(nul|prn|con|lpt[0-9]|com[0-9])(\.|$)/i // forbidden file names

            return (
                rg1.test(filename) && !rg2.test(filename) && !rg3.test(filename)
            )
        },
        createNewDoc(fileName) {
            const pages = Object.keys(this.selected)
                .filter((page) => this.selected[page])
                .map((page) => parseInt(page) - 1)

            let _newPdf

            PDFDocument.create()
                .then((pdfDoc) => (_newPdf = pdfDoc))
                .then((pdfDoc) => pdfDoc.copyPages(this.pdfDocument, pages))
                .then((copiedPages) => {
                    copiedPages.forEach((page) => _newPdf.addPage(page))
                    return _newPdf.save()
                })
                .then((pdfBytes) =>
                    download(pdfBytes, `${fileName}.pdf`, "application/pdf")
                )
                .catch((err) => {
                    this.$q.notify({
                        message: "Algo deu erro ao abrir o arquivo.",
                        color: "negative",
                    })
                    console.error(err)
                })
        },
        resetData() {
            Object.assign(this.$data, this.$options.data())
        },
    },
}
</script>

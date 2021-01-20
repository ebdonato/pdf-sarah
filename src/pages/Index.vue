<template>
    <q-page padding>
        <q-file
            outlined
            v-model="file"
            @input="pickerPDF"
            :disable="fileChosen"
        >
            <template v-slot:prepend>
                <q-icon name="attach_file" />
            </template>
        </q-file>
        <div
            class="fit row wrap justify-start items-start content-start q-my-sm"
        >
            <div v-for="page in numPages" :key="page">
                <q-checkbox v-model="selected[page]" :label="`${page}`" />
                <pdf :src="src" :page="page" />
            </div>
        </div>
        <q-page-sticky position="bottom-right" :offset="[18, 18]">
            <q-btn fab icon="get_app" color="accent" @click="createNewDoc" />
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
        createNewDoc() {
            const pages = Object.keys(this.selected)
                .filter((page) => this.selected[page])
                .map((page) => parseInt(page))

            let _newPdf

            PDFDocument.create()
                .then((pdfDoc) => (_newPdf = pdfDoc))
                .then((pdfDoc) => pdfDoc.copyPages(this.pdfDocument, pages))
                .then((copiedPages) => {
                    copiedPages.forEach((page) => _newPdf.addPage(page))
                    return _newPdf.save()
                })
                .then((pdfBytes) =>
                    download(
                        pdfBytes,
                        "pdf-lib_page_copying_example.pdf",
                        "application/pdf"
                    )
                )
                .catch(console.error)
        },
    },
}
</script>

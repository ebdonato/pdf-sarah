export function updateDefaultOutputFolderConfig(state, value) {
    state.defaultOutputFolder = !!value
}

export function updateClearSelectionConfig(state, value) {
    state.clearSelection = !!value
}

export function updateShowLinksConfig(state, value) {
    state.showLinks = !!value
}

export function updateLeftDrawerOpenConfig(state, value) {
    state.leftDrawerOpen = !!value
}

export function updateZoomLevelConfig(state, value) {
    if (value > 100) value = 100
    if (value < 10) value = 10

    state.zoomLevel = value
}

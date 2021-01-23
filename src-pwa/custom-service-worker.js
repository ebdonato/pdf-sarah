/*
 * This file (which will be your service worker)
 * is picked up by the build system ONLY if
 * quasar.conf > pwa > workboxPluginMode is set to "InjectManifest"
 */

//dependências - precaching
import { precacheAndRoute } from 'workbox-precaching'

//dependências - caching
import { registerRoute } from 'workbox-routing'
import { StaleWhileRevalidate } from 'workbox-strategies'

//configurações - precaching
precacheAndRoute(self.__WB_MANIFEST);

registerRoute(
    ({ url }) => url.href.startsWith('http'),
    new StaleWhileRevalidate()
)

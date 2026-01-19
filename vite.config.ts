import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'
import { VitePWA } from 'vite-plugin-pwa'

const manifest: any = {
  name: '性价比大PK',
  short_name: '性价比PK',
  description: '单位价格比对工具，为您选出最划算的商品',
  theme_color: '#3b82f6',
  background_color: '#f8fafc',
  display: 'standalone',
  icons: [
    {
      src: 'pwa-192x192.png',
      sizes: '192x192',
      type: 'image/png'
    },
    {
      src: 'pwa-512x512.png',
      sizes: '512x512',
      type: 'image/png'
    },
    {
      src: 'pwa-512x512.png',
      sizes: '512x512',
      type: 'image/png',
      purpose: 'maskable'
    }
  ]
};

// https://vite.dev/config/
export default defineConfig({
  plugins: [
    vue(),
    VitePWA({
      registerType: 'autoUpdate',
      includeAssets: ['favicon.svg', 'apple-touch-icon.png', 'favicon-32x32.png', 'favicon-16x16.png'],
      manifest
    })
  ],
  define: {
    __APP_NAME__: JSON.stringify(manifest.name),
    __APP_DESCRIPTION__: JSON.stringify(manifest.description)
  },
  base: '/price_pk/',
})

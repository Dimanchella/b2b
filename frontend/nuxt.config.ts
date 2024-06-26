/// js-source
// https://nuxt.com/docs/api/configuration/nuxt-config
import vuetify, {transformAssetUrls} from 'vite-plugin-vuetify'

// @ts-ignore
export default defineNuxtConfig({
  devtools: {enabled: true},
  build: {
    transpile: ['vuetify'],
  },
  modules: [
    '@sidebase/nuxt-auth',
    // @ts-ignore
    (_options, nuxt) => {
      nuxt.hooks.hook('vite:extendConfig', (config) => {
        // @ts-expect-error
        config.plugins.push(vuetify({autoImport: true}))
      })
    },
    '@pinia/nuxt',
    '@pinia-plugin-persistedstate/nuxt',
    '@sidebase/nuxt-session',
    'nuxt-schema-org',
  ],
  auth: {
    baseURL: process.env.AUTH_ORIGIN,
    provider: {
      type: 'authjs'
    },
    globalAppMiddleware: true,
    strategies: {
      cookie: {
        user: {
          property: false,
          autoFetch: true
        },
        endpoints: {
          login: {
            url: '/api/auth/login/',
            method: 'post',
            propertyName: false
          },
          logout: {
            url: '/api/auth/logout/',
            method: 'post',
            propertyName: false
          },
          csrf: {
            url: '/api/auth/csrf'
          }
        },
        tokenRequired: false,
        tokenType: false
      }
    }
  },
  vite: {
    vue: {
      template: {
        transformAssetUrls,
      },
    },
  },
  runtimeConfig: {
    authSecret: process.env.AUTH_SECRET,
    authOrigin: process.env.AUTH_ORIGIN,
    public: {
      djangoUrl: process.env.DJANGO_URL,
      imgUrl: process.env.IMG_URL,
    }
  },
  routes: 
  { 
    '/' : { prerender: true }, 
    '/*': { cors: true },
  },
  devServer: {
    host: '0.0.0.0',
    port: 3000,
  },
})

router: {
  middleware: ['auth']
}

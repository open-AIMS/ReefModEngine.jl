import { defineConfig } from 'vitepress'
import { tabsMarkdownPlugin } from 'vitepress-plugin-tabs'
import mathjax3 from "markdown-it-mathjax3";
import footnote from "markdown-it-footnote";

// https://vitepress.dev/reference/site-config
export default defineConfig({
  base: 'REPLACE_ME_DOCUMENTER_VITEPRESS',
  title: "ReefModEngine",
  description: "Julia interface to the ReefMod",
  lastUpdated: true,
  cleanUrls: true,
  outDir: 'REPLACE_ME_DOCUMENTER_VITEPRESS', // This is required for MarkdownVitepress to work correctly...
  head: [['link', { rel: 'icon', href: '/public/favicon.ico' }]],

  markdown: {
    math: true,
    config(md) {
      md.use(tabsMarkdownPlugin), md.use(mathjax3), md.use(footnote)
    },
    theme: {
      light: "github-light",
      dark: "github-dark"
    }
  },

  themeConfig: {
    outline: 'deep',
    // https://vitepress.dev/reference/default-theme-config
    // logo: { src: '/logo.png', width: 24, height: 24 },
    search: {
      provider: 'local',
      options: {
        detailedView: true
      }
    },
    nav: [
      { text: 'Home', link: '/' },
      { text: 'Getting Started', link: '/getting_started' },
      // {
      //   text: 'Examples',
      //   items: [
      //   ]
      // },

      { text: 'API', link: '/api' }
    ],

    sidebar: [
      {
        text: 'Getting Started', link: '/getting_started',
        // items: [
        //   { text: 'Link text', link: '/url_path' },
        // ]
      }
    ],
    editLink: {
      pattern: 'https://github.com/open-AIMS/ReefModEngine.jl/edit/main/docs/src/:path'
    },
    socialLinks: [
      { icon: 'github', link: 'https://github.com/open-AIMS/ReefModEngine.jl' }
    ],
    footer: {
      message: 'Made with <a href="https://luxdl.github.io/DocumenterVitepress.jl/" target="_blank"><strong>DocumenterVitepress.jl</strong></a> <br>',
      copyright: `© Copyright ${new Date().getUTCFullYear()}. Released under the MIT License.`
    }
  }
})
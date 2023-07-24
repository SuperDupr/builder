// See the Tailwind default theme values here:
// https://github.com/tailwindcss/tailwindcss/blob/master/stubs/defaultConfig.stub.js
const colors = require('tailwindcss/colors')
const defaultTheme = require('tailwindcss/defaultTheme')

/** @type {import('tailwindcss').Config */
module.exports = {
  plugins: [
    require('@tailwindcss/aspect-ratio'),
    require('@tailwindcss/forms'),
    require('@tailwindcss/typography'),
  ],

  content: [
    './app/helpers/**/*.rb',
    './app/javascript/**/*.js',
    './app/views/**/*.erb',
    './app/views/**/*.haml',
    './app/views/**/*.slim',
    './lib/jumpstart/app/views/**/*.erb',
    './lib/jumpstart/app/helpers/**/*.rb',
  ],

  // All the default values will be compiled unless they are overridden below
  theme: {
    // Extend (add to) the default theme in the `extend` key
    extend: {
      // Create your own at: https://javisperez.github.io/tailwindcolorshades
      colors: {
        primary: '#021642',
        secondary: colors.emerald,
        tertiary: colors.gray,
        danger: colors.red,
        "code-400": "#fefcf9",
        "code-600": "#3c455b",
      },
      spacing: {
      // Customize spacing values here
      '1': '4px',  
      '2': '8px',   
      '3': '12px',  
      '4': '16px',     
      '5': '20px',
      '50': '50px',
      '60': '60px', 
      '65': '65px',
      '70': '70px',  
      '80': '80px',
      '90': '90px',
      '100': '100px',
      '256': '256px'    
      // ...
    },
      fontFamily: {
        lato: ['Lato', 'sans-serif'],
      },
    },
  },

  // Opt-in to TailwindCSS future changes
  future: {
  },
}

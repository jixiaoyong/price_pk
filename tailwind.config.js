/** @type {import('tailwindcss').Config} */
export default {
    content: [
        "./index.html",
        "./src/**/*.{vue,js,ts,jsx,tsx}",
    ],
    theme: {
        extend: {
            screens: {
                'xs': '400px',
            },
            fontFamily: {
                sans: ['Inter', 'system-ui', 'sans-serif'],
            },
            animation: {
                'in': 'in 0.2s ease-out',
                'out': 'out 0.2s ease-in',
                'slide-in-from-bottom': 'slide-in-from-bottom 0.3s ease-out',
                'fade-in': 'fade-in 0.2s ease-out',
                'zoom-in-95': 'zoom-in-95 0.2s ease-out',
            },
            keyframes: {
                in: {
                    '0%': { opacity: '0' },
                    '100%': { opacity: '1' },
                },
                'slide-in-from-bottom': {
                    '0%': { transform: 'translateY(100%)' },
                    '100%': { transform: 'translateY(0)' },
                },
                'fade-in': {
                    '0%': { opacity: '0' },
                    '100%': { opacity: '1' },
                },
                'zoom-in-95': {
                    '0%': { opacity: '0', transform: 'scale(0.95)' },
                    '100%': { opacity: '1', transform: 'scale(1)' },
                },
            },
        },
    },
    plugins: [],
}

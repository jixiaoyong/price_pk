import { createI18n } from 'vue-i18n';
import zh from './locales/zh';
import en from './locales/en';

// 定义支持的语言类型
type LocaleType = 'zh' | 'en';

// 1. 获取本地缓存
const savedLocale = localStorage.getItem('user-locale') as LocaleType | null;

// 2. 获取浏览器语言 (如果没有缓存)
const getBrowserLocale = (): LocaleType => {
    // 如果无法获取 navigator 对象，默认返回中文
    if (typeof navigator === 'undefined') {
        return 'zh';
    }
    const navigatorLocale = navigator.language.toLowerCase();
    // 只有明确是英文环境才用英文，其他情况（包括无法识别）都默认中文
    return navigatorLocale.startsWith('en') ? 'en' : 'zh';
};

// 3. 决定最终语言：缓存 > 浏览器 > 默认 'zh'
const currentLocale = savedLocale || getBrowserLocale();

const i18n = createI18n({
    legacy: false, // 使用 Composition API 模式
    locale: currentLocale,
    fallbackLocale: 'zh', // 默认回退语言设为中文
    messages: {
        zh,
        en
    }
});

/**
 * 切换语言并持久化
 * @param locale - 要切换的目标语言
 */
export const setLocale = (locale: LocaleType) => {
    i18n.global.locale.value = locale;
    localStorage.setItem('user-locale', locale);
    // 更新 HTML 的 lang 属性
    document.documentElement.lang = locale;
};

export default i18n;

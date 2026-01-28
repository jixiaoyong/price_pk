<script setup lang="ts">
    import { ref, computed, onMounted, onUnmounted } from 'vue';
    import { ChevronDown, Check } from 'lucide-vue-next';
    import type { UnitInfo } from '../types';
    import { removeUnitBrackets } from '../utils/unitHelper';

    const props = defineProps<{
        modelValue: string;
        options: UnitInfo[];
    }>();

    const emit = defineEmits(['update:modelValue', 'dropdown-toggle']);

    const isOpen = ref(false);
    const containerRef = ref<HTMLElement | null>(null);

    // 计算当前选中的单位标签（去除括号后的简化版本）
    const selectedLabel = computed(() => {
        const selected = props.options.find(opt => opt.value === props.modelValue);
        const label = selected ? selected.label : props.modelValue;
        // 去除括号及其内容，使显示更简洁
        return removeUnitBrackets(label);
    });

    // 切换下拉菜单的打开/关闭状态
    const toggleOpen = () => {
        isOpen.value = !isOpen.value;
        emit('dropdown-toggle', isOpen.value);
    };

    // 选择一个单位选项
    const selectOption = (value: string) => {
        emit('update:modelValue', value);
        isOpen.value = false;
        emit('dropdown-toggle', false);
    };

    // 处理点击组件外部时关闭下拉菜单
    const handleClickOutside = (event: MouseEvent) => {
        if (containerRef.value && !containerRef.value.contains(event.target as Node)) {
            if (isOpen.value) {
                isOpen.value = false;
                emit('dropdown-toggle', false);
            }
        }
    };

    onMounted(() => {
        document.addEventListener('mousedown', handleClickOutside);
    });

    onUnmounted(() => {
        document.removeEventListener('mousedown', handleClickOutside);
    });
</script>

<template>
    <div class="relative h-full flex items-center" ref="containerRef">
        <button @click="toggleOpen"
            class="h-full px-3 flex items-center justify-end gap-1 text-xs font-bold transition-colors whitespace-nowrap min-w-[80px]"
            style="color: #007AFF;">
            <span>{{ selectedLabel }}</span>
            <ChevronDown class="w-3 h-3 flex-shrink-0 transition-transform" :class="{ 'rotate-180': isOpen }" />
        </button>

        <Transition enter-active-class="animate-in fade-in zoom-in-95 duration-100"
            leave-active-class="animate-out fade-out zoom-out-95 duration-75">
            <div v-if="isOpen" class="absolute right-0 top-full mt-1 w-48 rounded-xl shadow-xl overflow-hidden"
                style="background-color: #ffffff; border: 1px solid #f1f5f9; z-index: 999;">
                <div class="max-h-56 overflow-y-auto py-1">
                    <button v-for="opt in options" :key="opt.value" @click="selectOption(opt.value)"
                        class="w-full text-left px-4 py-3 text-xs font-medium flex items-center justify-between" :style="opt.value === modelValue
                            ? { color: '#007AFF', backgroundColor: 'rgba(239, 246, 255, 0.5)' }
                            : { color: '#475569', backgroundColor: 'transparent' }">
                        {{ opt.label }}
                        <Check v-if="opt.value === modelValue" class="w-3 h-3" />
                    </button>
                </div>
            </div>
        </Transition>
    </div>
</template>

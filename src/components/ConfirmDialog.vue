<script setup lang="ts">
    import { X } from 'lucide-vue-next';

    defineProps<{
        title: string;
        message: string;
        confirmText?: string;
        cancelText?: string;
        type?: 'danger' | 'primary';
    }>();

    defineEmits(['confirm', 'cancel']);
</script>

<template>
    <div
        class="fixed inset-0 z-[60] flex items-center justify-center bg-black/40 backdrop-blur-sm p-4 animate-in fade-in duration-200">
        <div class="bg-white w-full max-w-sm rounded-2xl p-6 shadow-2xl space-y-4 animate-in zoom-in-95 duration-200">
            <div class="flex justify-between items-center">
                <h3 class="text-lg font-bold text-slate-900">{{ title }}</h3>
                <button @click="$emit('cancel')" class="p-1 hover:bg-slate-100 rounded-full transition-colors">
                    <X class="w-5 h-5 text-slate-500" />
                </button>
            </div>

            <p class="text-slate-600 font-medium">
                {{ message }}
            </p>

            <div class="flex gap-3 pt-2">
                <button @click="$emit('cancel')"
                    class="flex-1 py-2.5 bg-slate-100 hover:bg-slate-200 text-slate-600 rounded-xl font-bold transition-colors">
                    {{ cancelText || '取消' }}
                </button>
                <button @click="$emit('confirm')"
                    class="flex-1 py-2.5 text-white rounded-xl font-bold transition-colors shadow-sm"
                    :class="type === 'danger' ? 'bg-red-500 hover:bg-red-600 shadow-red-200' : 'bg-[#007AFF] hover:bg-blue-600 shadow-blue-200'">
                    {{ confirmText || '确认' }}
                </button>
            </div>
        </div>
    </div>
</template>

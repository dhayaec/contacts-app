'use client';

import { useState } from 'react';
import { useCreateTodo } from '@/hooks/useTodos';
import type { CreateTodoInput } from '@/types/todo';

export function TodoForm() {
  const create = useCreateTodo();
  const [title, setTitle] = useState('');

  function handleSubmit(e: React.FormEvent<HTMLFormElement>) {
    e.preventDefault();
    if (!title.trim()) return;

    const input: CreateTodoInput = { title: title.trim(), completed: false };
    create.mutate(input, {
      onSuccess: () => setTitle(''),
    });
  }

  return (
    <form onSubmit={handleSubmit} className="flex gap-2">
      <input
        type="text"
        value={title}
        onChange={(e) => setTitle(e.target.value)}
        placeholder="Add a new todo..."
        className="flex-1 rounded border border-gray-300 px-3 py-2 text-black focus:border-blue-500 focus:outline-none focus:ring-1 focus:ring-blue-500"
        disabled={create.isPending}
      />
      <button
        type="submit"
        disabled={create.isPending || !title.trim()}
        className="rounded bg-blue-600 px-4 py-2 font-medium text-white transition hover:bg-blue-700 disabled:cursor-not-allowed disabled:opacity-50"
      >
        {create.isPending ? 'Adding...' : 'Add'}
      </button>
    </form>
  );
}

'use client';

import { useTodos } from '@/hooks/useTodos';
import { TodoItem } from '@/components/TodoItem';

export function TodoList() {
  const { data: todos, isLoading, isError, error } = useTodos();

  if (isLoading) {
    return (
      <div className="flex items-center justify-center py-12">
        <div className="h-8 w-8 animate-spin rounded-full border-4 border-gray-200 border-t-blue-600" />
        <span className="ml-3 text-gray-500">Loading todos…</span>
      </div>
    );
  }

  if (isError) {
    return (
      <div className="rounded border border-red-200 bg-red-50 px-4 py-3 text-red-700">
        <strong>Error:</strong> {(error as Error).message ?? 'Failed to load todos.'}
      </div>
    );
  }

  if (!todos?.length) {
    return (
      <p className="py-8 text-center text-gray-400">No todos yet. Add one above!</p>
    );
  }

  return (
    <ul className="mt-4 flex flex-col gap-2">
      {todos.map((todo) => (
        <TodoItem key={todo.id} todo={todo} />
      ))}
    </ul>
  );
}

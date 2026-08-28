'use client';

import { useState } from 'react';
import { useDeleteTodo, useUpdateTodo } from '@/hooks/useTodos';
import type { Todo } from '@/types/todo';

interface Props {
  todo: Todo;
}

export function TodoItem({ todo }: Props) {
  const update = useUpdateTodo();
  const remove = useDeleteTodo();
  const [editing, setEditing] = useState(false);
  const [title, setTitle] = useState(todo.title);

  function handleToggle() {
    update.mutate(
      { id: todo.id, input: { completed: !todo.completed } },
      { onError: () => {} }
    );
  }

  function handleSave() {
    if (!title.trim() || title === todo.title) {
      setEditing(false);
      return;
    }
    update.mutate(
      { id: todo.id, input: { title: title.trim() } },
      {
        onSuccess: () => setEditing(false),
      }
    );
  }

  function handleDelete() {
    remove.mutate(todo.id, { onError: () => {} });
  }

  const busy = update.isPending || remove.isPending;

  return (
    <li className="flex items-center gap-3 rounded border border-gray-200 bg-white px-4 py-3 shadow-sm">
      <input
        type="checkbox"
        checked={todo.completed}
        onChange={handleToggle}
        disabled={busy}
        className="h-5 w-5 cursor-pointer accent-blue-600"
      />

      {editing ? (
        <input
          type="text"
          value={title}
          onChange={(e) => setTitle(e.target.value)}
          onBlur={handleSave}
          onKeyDown={(e) => {
            if (e.key === 'Enter') handleSave();
            if (e.key === 'Escape') {
              setTitle(todo.title);
              setEditing(false);
            }
          }}
          autoFocus
          className="flex-1 rounded border border-blue-500 px-2 py-1 text-black focus:outline-none focus:ring-1 focus:ring-blue-500"
        />
      ) : (
        <span
          onClick={() => !busy && setEditing(true)}
          className={`flex-1 cursor-pointer text-gray-800 ${
            todo.completed ? 'line-through text-gray-400' : ''
          }`}
        >
          {todo.title}
        </span>
      )}

      <div className="flex gap-1">
        <button
          onClick={() => setEditing((v) => !v)}
          disabled={busy}
          className="rounded px-2 py-1 text-sm text-gray-500 transition hover:bg-gray-100 disabled:opacity-40"
        >
          {editing ? 'Cancel' : 'Edit'}
        </button>
        <button
          onClick={handleDelete}
          disabled={busy}
          className="rounded px-2 py-1 text-sm text-red-500 transition hover:bg-red-50 disabled:opacity-40"
        >
          Delete
        </button>
      </div>
    </li>
  );
}

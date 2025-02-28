-- Create the favorite_words table
CREATE TABLE public.favorite_words (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  text TEXT NOT NULL,
  user_id UUID NOT NULL REFERENCES auth.users(id),
  created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- Enable Row Level Security for the table
ALTER TABLE public.favorite_words ENABLE ROW LEVEL SECURITY;

-- Create a policy to allow users to select only their own words
CREATE POLICY "Users can view their own words"
ON public.favorite_words
FOR SELECT
USING (auth.uid() = user_id);

-- Create a policy to allow users to insert their own words
CREATE POLICY "Users can insert their own words"
ON public.favorite_words
FOR INSERT
WITH CHECK (auth.uid() = user_id);

-- Create indexes for better performance
CREATE INDEX favorite_words_user_id_idx ON public.favorite_words (user_id);
CREATE INDEX favorite_words_created_at_idx ON public.favorite_words (created_at);

